export type CellValue = string | boolean | Date

export type UnparsedItem = {[field:string]: CellValue | undefined}

export type Item = {
    "name": string
    "address": string
    "neighborhood": string
    "city": string
    "phone": string
    "category": string
    "description": string
    "date": Date
    "comments": string
    "email": string
    "isChecked": boolean
    "isCollected": boolean
}

export type Field = {
    name: string,
    required: boolean,
    checkForEmptyness: boolean
}


export const FIELDS: Field[] = [
    {name: "name", required: true, checkForEmptyness: true},
    {name: "address", required: true, checkForEmptyness: true},
    {name: "neighborhood", required: true, checkForEmptyness: true},
    {name: "city", required: true, checkForEmptyness: true},
    {name: "phone", required: true, checkForEmptyness: true},
    {name: "category", required: true, checkForEmptyness: true},
    {name: "description", required: true, checkForEmptyness: true},
    {name: "date", required: true, checkForEmptyness: true},
    {name: "comments", required: false, checkForEmptyness: true},
    {name: "email", required: true, checkForEmptyness: true},
    {name: "isChecked", required: true, checkForEmptyness: false},
    {name: "isCollected", required: true, checkForEmptyness: false},
]

export const KEY_COL_IDX = 1
export const FIRST_COL_IDX = 2

export const FORM_FIELDS = [
    "date", 
    "email", 
    "name", 
    "city",
    "neighborhood", 
    "address", 
    "phone", 
    "category", 
    "description", 
    "comments",
]