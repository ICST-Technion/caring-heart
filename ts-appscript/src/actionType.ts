import { Item, FIELDS, CellValue, UnparsedItem } from "./constants"
import { zip } from "./utils"


const isEmptyVal = (val: CellValue | undefined) => (val === undefined) || (val === '')
const isFullItem = (item: UnparsedItem, fields=FIELDS): item is Item => fields.every(({name: field, required}) => !required || !isEmptyVal(item[field]))

const isEmptyItem = (item: UnparsedItem, fields=FIELDS) => fields.every(({name, checkForEmptyness}) => !checkForEmptyness || isEmptyVal(item[name]))

export type ActionName = 'delete' | 'update' | 'create' | 'continue'
export type Action = 
  {
    isOk: true,
    type: ActionName
  } | 
  { isOk: false, message: string}

function getActionForEdit(isNew: boolean, isFull: boolean, isEmpty: boolean): Action{
  const okType = (type: ActionName) => {
    const action: Action = { 
      isOk: true,
      type
    }
    return action
  }
  if(isFull && isEmpty){
    return {
      isOk: false,
      message: 'Cannot be full and empty at the same time, check inputs and isFullItem(), isEmptyItem()'
    }
  }
  if(isNew){
    if(isFull){
      // it's new and the data is fully entered so we want to create it
      return okType('create')
    }else{
      // not filled all data yet, then continue
      return okType('continue')
    }
  }else{
    if(isEmpty){
      // item exists but deleted all data so we want to delete it completely
      return okType('delete')
    }else{
      if(isFull){
        // item exists and all data inserted, that means it's a valid state after change so we can update
        return okType('update')
      }else{
        // item exists but in an intermidiate state so we don't want to update it
        return okType('continue')
      }
    }
  }
}


/**
 * returns {
 *  isOk: boolean // whether it's a valid state
 *  error?: string // error message is !isOk
 *  type?: // 'delete' | 'update' | 'create' | 'contine' if isOk
 * }
 */

export function getActionType(key: string | undefined, item: UnparsedItem): Action {
  const isNew = !isEmptyVal(key)
  const isFull = isFullItem(item)
  const isEmpty = isEmptyItem(item)
  const action = getActionForEdit(isNew, isFull, isEmpty)
  return action
}

// export function _getActionType({key, item}: {key: string | undefined, item: UnparsedItem}): {action: Action, isThisFullItem: (item: UnparsedItem) => item is Item} {
//   const isNew = !isEmptyVal(key)
//   const isFull = isFullItem(item)
//   const isEmpty = isEmptyItem(item)
//   const action = getActionForEdit(isNew, isFull, isEmpty)
//   return {action, isThisFullItem: (i: UnparsedItem): i is Item => isFull && action.isOk}
// }
// type ItemKeyPair<ItemType extends UnparsedItem> = {item: ItemType, key: string | undefined}

// type ChangesClassifier = (itemKeyPairs: ItemKeyPair<UnparsedItem>[]) => {
//   creates: ItemKeyPair<Item>[]
//   updates: ItemKeyPair<Item>[]
//   deletes: ItemKeyPair<UnparsedItem>[]
//   continues: ItemKeyPair<UnparsedItem>[]
//   errors?: ItemKeyPair<UnparsedItem>[]
// }

// const classifyItems: ChangesClassifier = (itemKeyPairs: {item: UnparsedItem, key: string | undefined}[], actionTypeGetter = _getActionType) => {
//   const actions = itemKeyPairs.map(ikp => actionTypeGetter(ikp))
//   return {
//     creates: zip(itemKeyPairs, actions).filter(([{item, key}, {action, isThisFullItem}]) =>
//      action.isOk && isFullItem(item) && action.type == 'create').map(([{item, key}, {action, isThisFullItem}]) => ({item, key}))
//   }
// }

