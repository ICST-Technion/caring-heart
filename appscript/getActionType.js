const isEmptyVal = (val) => (val === undefined) || (val === '')
const isFullItem = (item, fields=constants.FIELDS) => fields.every(({name: field, required}) => !required || !isEmptyVal(item[field]))

const isEmptyItem = (item, fields=constants.FIELDS) => fields.every(({name, checkForEmptyness}) => !checkForEmptyness || isEmptyVal(item[name]))

/**
 * returns {
 *  isOk: boolean // whether it's a valid state
 *  error?: string // error message is !isOk
 *  type?: // 'delete' | 'update' | 'create' | 'contine' if isOk
 * }
 */
function getActionForEdit(isNew, isFull, isEmpty){
  const okType = (type) => ({
    isOk: true,
    type
  })
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
      if(isEmpty)
      {
        //empty line
        return okType('empty')
      }else{
      // not filled all data yet, then continue
      return okType('continue')
      }
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

function getActionType(key, item) {
  const isNew = !(!!key)  // when key is undefined or ''
  const isFull = isFullItem(item)
  const isEmpty = isEmptyItem(item)

  const action = getActionForEdit(isNew, isFull, isEmpty)
  return action
}
