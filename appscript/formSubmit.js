// ["19/12/2021 21:11:09","caringhearttech@gmail.com","hbjkbj,","חיפה","  j,,jn","n,knm","0544988198","knbkjn","",""]

function formDateStringToDate(dateString){
  const date = dateString.split(' ')[0]
  const [day, month, year] = date.split('/')
  return new Date(`${month}/${day}/${year}`)
}

function formValuesToItem(values, formFields){
  let item = Object.fromEntries(zip(formFields, values))
  item.date = formDateStringToDate(item.date)
  item.phone = ''+item.phone
  return {...item, isCollected: false, isChecked: false}
}

function onFormSubmit(e, formFields=constants.FORM_FIELDS, addToSheets=true) {
  const item = formValuesToItem(e.values, formFields)
  const inventory = getInventory()
  console.log(`Submitted new item to form: ${JSON.stringify(item)}`)
  inventory.addItem(item)
  console.log('Succefully uploaded item to database!')
}
