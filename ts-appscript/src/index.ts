/// FirestoreApp plugin docs at https://github.com/grahamearley/FirestoreGoogleAppsScript

import { Action, ActionName, getActionType } from "./actionType"
import { CellValue, FIELDS, FIRST_COL_IDX, FORM_FIELDS, Item, KEY_COL_IDX, UnparsedItem } from "./constants"
import { getInventory } from "./database"
import { formValuesToItem } from "./parsing"
import { rangeArr, zip, zip4 } from "./utils"


function getValues(
    sheet: GoogleAppsScript.Spreadsheet.Sheet,
    row: number,
    n_rows: number,
    first_col=FIRST_COL_IDX,
    key_col=KEY_COL_IDX,
    num_cols=FORM_FIELDS.length) : {values: CellValue[][], keys: string[]} {

  const values: CellValue[][] = sheet.getRange(row, first_col, n_rows, num_cols).getValues()
  const keys2d: string[][] = sheet.getRange(row, key_col , n_rows, 1).getValues()
  const keys = keys2d.reduce((prev, [curr]) => [...prev, curr], [])
  return {values, keys}
}

function parseValues(values: CellValue[][], fields = FIELDS.map(f => f.name)): UnparsedItem[]{
  return values.map((row: CellValue[]) => formValuesToItem<UnparsedItem>(row, fields, {}))
}

/**
 * @param {Event} e The onEdit event.
 */
function updateDatabaseOnEdit(e: GoogleAppsScript.Events.SheetsOnEdit) {
  // Set a comment on the edited cell to indicate when it was changed.
  const range = e.range
  const row = range.getRow()
  const sheet = range.getSheet()
  const n_rows = range.getNumRows()

  const {values, keys} = getValues(sheet, row, n_rows)
  const rowsIdxs = rangeArr(row, row + n_rows + 1)
  const items = parseValues(values)

  const actions = zip(keys, items).map(([key, item]) => getActionType(key, item))

  type ItemDataAction = {action : Action, key: string, item: UnparsedItem, row: number}
  type ValidItemDataAction = ItemDataAction & {action: {isOk: true}}
  type NotValidItemDataAction = ItemDataAction & {action: {isOk: false}}

  const itemsAndAction: ItemDataAction[] = zip4(keys, items, rowsIdxs, actions).map(([key, item, row, action]) => ({action, key, item, row}))
  
  const notValidItems : NotValidItemDataAction[] = itemsAndAction.filter((ida): ida is NotValidItemDataAction => !ida.action.isOk)
  
  if(notValidItems.length > 0){
    SpreadsheetApp.getUi().alert(
      `שגיאה! דווחו למפתחים:
      ${notValidItems[0].action.message}
      items with error:
      ${notValidItems.map(i => `key: ${i.key}\n${JSON.stringify(i.item)}`).join('\n')}
      `
    )
    return undefined
  }
  const getItemsByAction = (actionType: ActionName) => 
    itemsAndAction.filter((ida): ida is ValidItemDataAction => 'type' in ida.action && ida.action.type == actionType)
  
  const allActions: ActionName[] = ['delete', 'update', 'create', 'continue']
  const [deletes, updates, creates, continues] = allActions.map(getItemsByAction)
  console.log({deletes, updates, creates, continues})
  const inventory = getInventory()
  const getKeyCell = (row: number) => sheet.getRange(row, KEY_COL_IDX)
  updates.forEach(({key, item}) => {
    inventory.updateItem(key, item as Item)
    SpreadsheetApp.getActive().toast('עודכן פריט!')
  })
  creates.forEach(({item, row}) => {
    const newKey = inventory.addItem(item as Item)
    getKeyCell(row).setValue(newKey)
    SpreadsheetApp.getActive().toast('נוסף פריט חדש!')
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

function uiDialogMaker(title: string, text: string){
  const ui = SpreadsheetApp.getUi()
  return ui.alert(
    title,
    text,
    ui.ButtonSet.YES_NO
  ) == ui.Button.YES
}

function simpleDialog(title: string, text:string, yesAction: () => void, noAction: () => void, dialogMaker = uiDialogMaker){
  const isPositive = dialogMaker(
    title,
    text)
  if (isPositive) {
    yesAction()
  } else {
    noAction()
  }
}
  