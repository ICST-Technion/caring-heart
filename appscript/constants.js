const constants = {
  KEY_COL_IDX: 1,
  FIRST_COL_IDX: 2,
  LAST_COL_IDX: 14,
  FIELDS: [
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
  ],
  FORM_FIELDS: [
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

}
