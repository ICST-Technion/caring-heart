/// FirestoreApp plugin docs at https://github.com/grahamearley/FirestoreGoogleAppsScript

function _assertCredObject(credObj){
  if(!(!!credObj && ("project_id" in credObj) && ("client_email" in credObj) && ("private_key" in credObj))){
    console.log(!!credObj, ("project_id" in credObj), ("client_email" in credObj), ("private_key" in credObj))
    console.error('Error! credJson object is not valid')
    look_up_for_the_printed_error;
  }
}

function saveServiceAccountInProperties(){
  // object with project_id, client_email, private_key
  const credObj = null;
  _assertCredObject(credObj)

  const credString = JSON.stringify(credObj)

  const scriptProperties = PropertiesService.getScriptProperties()
  scriptProperties.setProperty("serviceAccount", credString)
}

function loadServiceAccount(){
  const scriptProperties = PropertiesService.getScriptProperties()
  const serviceAccountString = scriptProperties.getProperty("serviceAccount")
  const serviceAccount = JSON.parse(serviceAccountString)

  _assertCredObject(serviceAccount)
  
  return serviceAccount

}

function getFirestore() {
  const config = loadServiceAccount()
  return FirestoreApp.getFirestore(config.client_email, config.private_key, config.project_id)
}

const firestore = {
  _instance: null,
  getInstance: function(){
    if(!!!this._instance){
      this._instance = getFirestore()
    }
    return this._instance
  }
}

function prepItemForDb(item){
  delete item.fromFirebase
  item.fromSheets = true
  return item
}

function getInventory(collection="inventoryTest", firestoreProvider=firestore.getInstance){
  const firestoreInstance = firestoreProvider()
  return {
    addItem: function(item, fromSheets=true){
      if(fromSheets){
        item = prepItemForDb(item)
      }else{
        item.fromSheets = false;
      }
      const doc = firestoreInstance.createDocument(collection, item)
      const [_collection, key] = doc.path.split('/')
      return key
    },
    removeItem: function(key){
      firestoreInstance.deleteDocument(`${collection}/${key}`)
    },
    updateItem: function(key, newItem, override=true){
      console.log(`to firebase ${newItem}`)
      firestoreInstance.updateDocument(`${collection}/${key}`, prepItemForDb(newItem), !override)
    }
  }
}
