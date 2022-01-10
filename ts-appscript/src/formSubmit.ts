// ["19/12/2021 21:11:09","caringhearttech@gmail.com","hbjkbj,","חיפה","  j,,jn","n,knm","0544988198","knbkjn","",""]

import { CellValue, FORM_FIELDS, Item } from "./constants"
import { getInventory } from "./database"
import { formValuesToItem } from "./parsing"


export function formDateStringToDate(dateString: string): Date{
  const date = dateString.split(' ')[0]
  const [day, month, year] = date.split('/')
  return new Date(`${month}/${day}/${year}`)
}

export type DataConvertor = {
  [fieldName: string] : (originalValue: CellValue) => CellValue
} 

export const convertFormsValues: DataConvertor = {
  phone: (originalValue: CellValue) => '' + originalValue,
  date: (originalValue: CellValue) => formDateStringToDate(originalValue as string),
}

export function onFormSubmit(e: GoogleAppsScript.Events.SheetsOnFormSubmit, formFields=FORM_FIELDS) {
  const item = formValuesToItem<Item>(e.values, formFields)
  const inventory = getInventory()
  console.log(`Submitted new item to form: ${JSON.stringify(item)}`)
  inventory.addItem(item)
  console.log('Succefully uploaded item to database!')
}
