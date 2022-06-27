/// FirestoreApp plugin docs at https://github.com/grahamearley/FirestoreGoogleAppsScript


/**
 * returns {values: string[][] of values in the range in the sheet, keys: string[] of corresponding keys}
 */
function getValues(sheet, row, n_rows, first_col=constants.FIRST_COL_IDX, key_col = constants.KEY_COL_IDX,num_cols=constants.LAST_COL_IDX - constants.FIRST_COL_IDX + 1){
  const values = sheet.getRange(row, first_col, n_rows, num_cols).getValues()
  const keys2d = sheet.getRange(row, key_col , n_rows, 1).getValues()
  const keys = keys2d.reduce((prev, [curr]) => [...prev, curr], [])
  return {values, keys}
}

function parseValues(values, fields = constants.FIELDS){
  const rowTofieldValuePairs = (row) => fields.map(({name}, idx) => [name, row[idx]])
  const items = values.map(row => Object.fromEntries(rowTofieldValuePairs(row)))
  return items
}


function toast(range){
  const values = range.getValues()
  SpreadsheetApp.getActive().toast(`${range.getA1Notation()}: ${values ? values: 'deleted'}`)
}

function prettyItemsString(items){
  const headers = Object.keys(items[0]).join(' | ') + '\n'
  return headers + items.map(Object.values).map(arrValues => arrValues.join(' | ')).join('\n')
}



/**
 * @param {Event} e The onEdit event.
 */
function updateDatabaseOnEdit(e) {
  // Set a comment on the edited cell to indicate when it was changed.
  const range = e.range
  const row = range.getRow()
  if (row == 1 || row ==2){
    return;
  }

  Logger.log( JSON.stringify( e , null, 2 ) );

  const sheet = range.getSheet()
  const n_rows = range.getNumRows()

  const {values, keys} = getValues(sheet, row, n_rows)
  const rowsIdxs = rangeArr(row, row + n_rows + 1)
  const items = parseValues(values)

  const actions = zip(keys, items).map(([key, item]) => getActionType(key, item))
  /** {key, item, row, action}[] */
  const itemsAndAction = zip(keys, items, rowsIdxs, actions).map(([key, item, row, action]) => ({action, key, item, row}))

  const notValidItems = itemsAndAction.filter(({action}) => !action.isOk)
  if(notValidItems.length > 0){
    SpreadsheetApp.getUi().alert(
      `שגיאה! דווחו למפתחים:
      ${notValidItems[0].action.message}
      items with error:
      ${notValidItems.map(i => `key: ${i.key}\n${JSON.stringify(i.item)}`).join('\n')}
      `
    )
    return
  }
  const getItemsByAction = (actionType) => itemsAndAction.filter(({action: {type}}) => type == actionType)
  const [deletes, updates, creates, continues,empties] = ['delete', 'update', 'create', 'continue', 'empty'].map(getItemsByAction)
  console.log({deletes, updates, creates, continues})
  const inventory = getInventory()
  const getKeyCell = (row) => sheet.getRange(row, constants.KEY_COL_IDX)
  
  const setRowColor = (row, color) => {
    r = sheet.getRange(row,constants.FIRST_COL_IDX,1, constants.LAST_COL_IDX)
    r.clearFormat()
    r.setBackground(color)
  }

  continues.forEach(({item, row}) => {    
    setRowColor(row,"yellow")
    
  })
  empties.forEach(({item, row}) => {    
    setRowColor(row,"lightgray")
    
  })

  updates.forEach(({key, item}) => {
    inventory.updateItem(key, item)
    SpreadsheetApp.getActive().toast('עודכן פריט!')
    setRowColor(row,"white")
  })
  creates.forEach(({item, row}) => {
    const newKey = inventory.addItem(item)
    getKeyCell(row).setValue(newKey)
    SpreadsheetApp.getActive().toast('נוסף פריט חדש!')
    setRowColor(row,"white")
  })
  if(deletes.length > 0){
    const rowsBottomToTop = deletes.map(d => d.row).sort().reverse()
    const title = 'מחיקת פריטים'
    const text = 'האם אתה בטוח שאתה רוצה למחוק את הפריטים בשורות ' + rowsBottomToTop.join() + '?'
    const removeAction = () => {
      deletes.forEach(({key}) => {
        inventory.removeItem(key)
      })
      for(const row of rowsBottomToTop){
        sheet.deleteRow(row)
      }
    }
    const cancelAction = () => undefined  // do nothing
    simpleDialog(title, text, removeAction, cancelAction)
  }

}

function uiDialogMaker(title, text){
  const ui = SpreadsheetApp.getUi()
  return ui.alert(
    title,
    text,
    ui.ButtonSet.YES_NO
  ) == ui.Button.YES
}

function simpleDialog(title, text, yesAction, noAction, dialogMaker = uiDialogMaker){
  const isPositive = dialogMaker(
    title,
    text)
  if (isPositive) {
    yesAction()
  } else {
    noAction()
  }
}

function createNewSheetByMonth(){
  var date = new Date()
  date = new Date(Utilities.formatDate(date, SpreadsheetApp.getActiveSpreadsheet().getSpreadsheetTimeZone(), "yyyy-MM-dd'T'HH:mm:ss"))
  var month = date.getMonth() +1
  var year = date.getFullYear() - 2000
  var name = month.toString() + "/" + year.toString()
  var source = SpreadsheetApp.getActiveSpreadsheet()
  if (!source.getSheetByName(name)){

  var sheet = source.getSheetByName("template")
  var dest = sheet.copyTo(source)
  dest.setName(name).activate()
  
  var rangesToProtect = ["A:B", "1:2"]
  rangesToProtect.forEach((r) => {
    dest.getRange(r).protect().removeEditor("levchash@levchash.co.il")
  })
  //dest.getRange("K3:K").setNumberFormat("dd/mm/yyy")
  
  //dest.activate()
  //dest.getRange("A:B").protect().removeEditor("");
  //dest.getRange("1:1").protect();
  }
  
}


function createNewSheetByMonthTest(){
  var date = new Date()
  date = new Date(Utilities.formatDate(date, SpreadsheetApp.getActiveSpreadsheet().getSpreadsheetTimeZone(), "yyyy-MM-dd'T'HH:mm:ss"))
  //console.log(Utilities.formatDate(date, SpreadsheetApp.getActiveSpreadsheet().getSpreadsheetTimeZone(), "yyyy-MM-dd"))
  //console.log(date)
  //return
  var month = date.getMonth() +3
  var year = date.getFullYear() - 2000
  var name = month.toString() + "/" + year.toString()
  var source = SpreadsheetApp.getActiveSpreadsheet()
  if (!source.getSheetByName(name)){

  var sheet = source.getSheetByName("template")
  var dest = sheet.copyTo(source)
  dest.setName(name).activate()
  
  var rangesToProtect = ["A:B", "1:2"]
  rangesToProtect.forEach((r) => {
    dest.getRange(r).protect().removeEditor("levchash@levchash.co.il")
  })
  
  }
  
}

function lastValue(sheetName) {  
  

  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheetName)
  var lastRow = sheet.getMaxRows();
  
  var values = sheet.getRange("A1:A" + lastRow).getValues();

  for (; values[lastRow - 1] == "" && lastRow > 0; lastRow--) {}
  
  
  return lastRow + 1;
}

