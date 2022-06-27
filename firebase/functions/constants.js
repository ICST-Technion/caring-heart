exports.constants = {
  SPREADSHEET_IDS: {
    TEST: '1X1q6YAQdXoEmkUn2KhygDzswDlwZ8epW2NL3jSu1tj0',
    PRODUCTION: '10b4vqS0cbBlqLuDGgSyOljJaCziwTYyHfReQq6jdRdg',
  },
  COLLECTIONS: {
    TEST: {
      INVENTORY: 'inventoryTest',
      REPORTS: 'reportsTest',
    },
    PRODUCTION: {
      INVENTORY: 'inventory',
      REPORTS: 'reports',
    }
  },
  
  KEY_COL_IDX: 1,
  FIRST_COL_IDX: 2,
  LAST_COL_IDX: 15,
  LAST_COL_LETTER: "O",
  DATE_IDX:10,
  Default_Sheet: "Sheet1",

  FIELDS: [
    {name: "name", required: true, checkForEmptyness: true},
    {name: "address", required: true, checkForEmptyness: true},
    {name: "floor", required: true, checkForEmptyness: true},
    {name: "apartment", required: true, checkForEmptyness: true},
    {name: "neighborhood", required: false, checkForEmptyness: true},
    {name: "city", required: true, checkForEmptyness: true},
    {name: "phone", required: true, checkForEmptyness: true},
    {name: "description", required: true, checkForEmptyness: true},
    {name: "date", required: true, checkForEmptyness: true},
    {name: "comments", required: false, checkForEmptyness: true},
    {name: "email", required: false, checkForEmptyness: true},
    {name: "isChecked", required: true, checkForEmptyness: false},
    {name: "isCollected", required: true, checkForEmptyness: false},
  ],
  FORM_FIELDS: [
    "date", 
    "email", 
    "name", 
    "city",
    "neighborhood", 
    "address",
    "phone", 
    "description", 
    "comments",
    "floor",
    "apartment",
  ]
}
