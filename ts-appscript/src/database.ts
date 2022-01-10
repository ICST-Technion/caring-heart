/// FirestoreApp plugin docs at https://github.com/grahamearley/FirestoreGoogleAppsScript

import { Item } from "./constants"


declare var FirestoreApp: any 

function getFirestore() {
  const config = {
    "project_id": "caring-heart-aa1c1",
    "client_email": "caring-heart-aa1c1@appspot.gserviceaccount.com",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC1iGCvbP/a3KrG\nyzsUin6yY8CXHd001UA9tDsONdd4h7DDbz3MpzyOxj0rne9m1v+VmAddqV3iriFH\n1C4BTfJEsGjWLBT43hWfO3ndLZ7+qvjoIraXa/Ohe2RJPlMB9vvL8SsJBtpMp1J9\nozxlFXTsxrSEAGJwrhWPVTvEXMTvjhAYtKHA5u/Iu4cYSucNUbqG955AbC0uWUl2\nleQFzvOvJGAlzui9BHnUVwUevRbkEa4ukgX1BQE4WRXGStKW8CFwmIC6+J5VqOGD\ndJQwuforePoRBxqs/hWrOaPajrqy5l6+AYUvZuiK6/3zHt2atjYU1zHykAD160ks\nY1GdwDNNAgMBAAECggEACvmjENAX+uk2+PxeBsylws7FnM1NK63N670bCe2m6I5Z\nmUM/OwGMZ3xkQ+ARUoginS57GYZNGxCYigFxw5ntEQqSWAqDvRUePQmJQV5J+88l\n69D3dZms+eEeK9B1D8wZJpge2DWeGp7OHbLyCpF8x3ju/oEQcowP2SHX0nQiYvI7\nORlDfQnEp5YCyOOeCvWRGYPyDGFJrUk2kJT93rE2C9eo4m9VGVHtXttKfbUR+US+\npLAUAiJczbUmWBiEAPPcbbYLDT2+CtkgmLayzbcno3+LFH6hUC0O0aAPy2Dy1YOe\n1QszU+axZPIIKbrwxemE22S16weXxuoaS5Gl735FoQKBgQD6s5yvoeS5fMiZP3wg\ngu8AD3Px6fh7qHA4nQwGhuPd6CzVHkjhPKjxImVOQFuz+lOOALPdRLULExSWT4e8\nrGZdHhNaVbD2Sr63lJkzlUPHFdNNc1vgHhXoKqN4x7onK0W5djwkHeDVHd/YCspd\nuvV5UwShKgOxZZ0ynhhy3gCM7QKBgQC5XolYr45vY4l2RuBzYgN9Y6C2Dny8MfDk\nq4AcvKGsSDze72j8Ky8eXIUIz2MSGL+Rp4eiQSCXJgeds5noF//2QtJfvAxHI2gw\nTq+7fIhQ3Bm1VfRhIGqb6JVuMNeRICAptB6UzFNKKFscP2KRbNNX/Nr1+qLW/Dos\nvPoG4PHT4QKBgQDsnOS/Jw8Wud0iNjbTAIDOD8eghPDO1RTFegPFjT43TFAz/NdQ\nLc5Nd+chScDDRvnhRmx748LzZtjBXOKBgj1CmYYudj4E1lrWLVvCwZgsqD68FKqc\nBgkrDEMpVWguW7r85cixVbnDquR/pP+GI1RXY7E04tCFd6A8C9aLY1glqQKBgQCI\nieLfCUkAMTAih+hx9OMfLBBHqXolYR/QP6b5A9SOQxNbHruU6vYlBf8T0zZlMQeC\ncQUN9azcyK1Zct5Nv8fRC71LuQbOK31l/7+feQYrkUP6dtqv5CHCv1m6NY3DHwex\n0DOqZKqA+CLMNsAS4Db4G47pGnlxo43yQCxmfrCB4QKBgQD6X2eqK1wL5cwU9Nvq\nBEMT/gipLQteabJNRgHG2lvJVijqzrg1X7yoIVSEDqHE3rf5CFaw6WyH8UAoDSyf\n18wc5VaWhxZqiLNkuYmXzG34vDrNcwIxIoUXNNNOIa76Bz2KhwdQlU26+mtBXXQy\ntWMJ5+ygjVJasQugK8LTTnb7cA==\n-----END PRIVATE KEY-----\n"
  }
  return FirestoreApp.getFirestore(config.client_email, config.private_key, config.project_id)
}


let firestore: any = null


interface Inventory{
  /**
   * Creates new item, returns key of the new item
   */
  addItem: (item: Item) => string
  removeItem: (key: string) => void
  updateItem: (key: string, newItem: Item) => void
  getItem: (key: string) => Item
} 

export function getInventory(collection="inventoryTest", firestoreProvider = () => {return (firestore || (firestore = getFirestore()))}): Inventory{
  const firestoreInstance = firestoreProvider()
  return {
    addItem: function(item){
      const doc = firestoreInstance.createDocument(collection, item)
      const [_collection, key] = doc.path.split('/')
      return key
    },
    removeItem: function(key){
      firestoreInstance.deleteDocument(`${collection}/${key}`)
    },
    updateItem: function(key, newItem, override=true){
      firestoreInstance.updateDocument(`${collection}/${key}`, newItem, !override)
    },
    getItem: function(key) {
      return firestoreInstance.getDocument(`${collection}/${key}`)
    }
  }
}
