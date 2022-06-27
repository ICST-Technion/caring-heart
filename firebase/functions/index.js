const functions = require("firebase-functions");
const { google } = require("googleapis");
const sheets = google.sheets("v4");
const { constants } = require("./constants");


const FORMAT_FIELDS = {
    date: formatDate,
}

function format(field, value, format_fields=FORMAT_FIELDS){
    if(field in format_fields)
        return format_fields[field](value);
    return value;
}

const docPath = collection => `/${collection}/{documentId}`;


const serviceAccount = require("./serviceAccount.json");

const jwtClient = new google.auth.JWT({
    email: serviceAccount.client_email,
    key: serviceAccount.private_key,
    scopes: ["https://www.googleapis.com/auth/spreadsheets"],
});
const jwtAuthPromise = jwtClient.authorize();
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

function newSheetLineFromFirebase(spreadsheetId, snap, context){
    const data = snap.data();
    data.fromSheets = data.fromSheets ?? false;
    
    if (data.fromSheets){
        return snap.ref.set({ fromSheets: false}, {merge: true});
    }
    const values = getRowValues(data, context.params.documentId);
    let sheetName = getSheetName(values[0][constants.DATE_IDX]);
    if (!isSheetExists(spreadsheetId, sheetName)){
        sheetName = constants.Default_Sheet;
    }
    return sheetAppendLine(spreadsheetId, values, sheetName);
}

exports.createSheets = functions.firestore.document(docPath(constants.COLLECTIONS.TEST.INVENTORY))
    .onCreate((snap, context) => newSheetLineFromFirebase(constants.SPREADSHEET_IDS.TEST, snap, context));

exports.createSheets = functions.firestore.document(docPath(constants.COLLECTIONS.PRODUCTION.INVENTORY))
    .onCreate((snap, context) => newSheetLineFromFirebase(constants.SPREADSHEET_IDS.PRODUCTION, snap, context));

function getRowValues(data, documentId) {
    const columnData = constants.FIELDS.map(field => format(field.name, data[field.name]) ?? '');
    const values = [[documentId, true, ...columnData]];
    return values;
}

function between(min, max) {  
    return Math.floor(
      Math.random() * (max - min) + min
    )
  }

async function sheetAppendLine(spreadsheetId, values, sheetName) {
    const row = between(2,850)
    const col = String.fromCharCode(between(65,90))    
    sheetsUpdate(spreadsheetId, [[""]], `LookUp_Sheet789!${col}${row}`, "USER_ENTERED").then(( _) => {
    let formula = `=lastValue("${sheetName}")`;
        sheetsUpdate(spreadsheetId, [[formula]], `LookUp_Sheet789!${col}${row}`, "USER_ENTERED").then(( response) => {
            const line = response.data.updatedData.values[0][0];
            functions.logger.log(`Found line ${line}`);            
            sheetsUpdate(spreadsheetId, values, `${sheetName}!A${line}:${constants.LAST_COL_LETTER}${line}`, "USER_ENTERED");            
            
        });
    });
}

async function updateSheetLineFromFirebase(spreadsheetId, change, context){
    const data = change.after.data();
    functions.logger.log("RUNNING updateSheets() with new data", data);
    if (data.fromSheets){
        functions.logger.log("Change is from sheets");
        return change.after.ref.set({ fromSheets: false}, {merge: true});
    }
    functions.logger.log("Change is not from sheets");
    if (change.before.data().fromSheets && !data.fromSheets){
        functions.logger.log("Change was prev. from sheets, now it's not");
        return null;
    }
    let sheetName = getSheetName(formatDate(data.date));
    if (!isSheetExists(spreadsheetId, sheetName)){
        sheetName = constants.Default_Sheet;
    }
    let formula = `=MATCH("${context.params.documentId}", '${sheetName}'!A:A, 0)`;
    sheetsUpdate(spreadsheetId, [[formula]], "LookUp_Sheet789!A1", "USER_ENTERED").then(( response) => {
        const line = response.data.updatedData.values[0][0];
        functions.logger.log(`Found line ${line}`);
        const values = getRowValues(data, context.params.documentId);
        functions.logger.log(`Col values are`, values);
        if (isNaN(line)){
            sheetAppendLine(spreadsheetId, values, sheetName);
        }
        else{
            sheetsUpdate(spreadsheetId, values, `${sheetName}!A${line}:${constants.LAST_COL_LETTER}${line}`, "USER_ENTERED");
        }
    });
}

exports.updateSheets = functions.firestore.document(docPath(constants.COLLECTIONS.TEST.INVENTORY))
    .onUpdate((change, context) => updateSheetLineFromFirebase(constants.SPREADSHEET_IDS.TEST, change, context));

exports.updateSheets = functions.firestore.document(docPath(constants.COLLECTIONS.PRODUCTION.INVENTORY))
    .onUpdate((change, context) => updateSheetLineFromFirebase(constants.SPREADSHEET_IDS.PRODUCTION, change, context));

async function sheetsUpdate(spreadsheetId, values, range, valueInputOption) {
    await jwtAuthPromise;
    return sheets.spreadsheets.values.update({
        auth: jwtClient,
        spreadsheetId: spreadsheetId,
        range: range,
        valueInputOption: valueInputOption,
        includeValuesInResponse: true,
        resource: {
            values: values
            ,
        },
    },
        {}
    );
}
function formatDate(timestamp)
{
    if (typeof timestamp === 'string' || timestamp instanceof String) {
        return timestamp;
    }
    const date = timestamp.toDate();
    return `${date.getUTCDate()}/${date.getMonth()+1}/${date.getFullYear()}`;
}

async function isSheetExists(spreadsheetId, sheetName)
{
    let formula = `=ISREF('${sheetName}'!A1)`;
    await sheetsUpdate(spreadsheetId, [[formula]], "LookUp_Sheet789!A3", "USER_ENTERED", spreadsheetId).then(( response) => {
        const result = response.data.updatedData.values[0][0];
        return result.toLowerCase().startsWith("true");

    }, (reason)=> {
        return false;
    });
}

function getSheetName(dateField) {
    try{
        const arr = dateField.split("/");
        if (!arr || !arr.length || arr.length !=3){
            return constants.Default_Sheet;
        }
        const month = parseInt(arr[1]);
        const year = parseInt(arr[2]) -2000;
        if (month <1 || month >12 || year <0){
            return constants.Default_Sheet;
        }
        return `${month}/${year}`;

    }
    catch{
        return constants.Default_Sheet;
    }
}

function isVisited(reportData){
    return ['collected', 'canceled'].includes(reportData?.status); 
}

async function updateIsCollectedOnReport (inventoryCollection, change, context) {
    const isReportCollected = isVisited(change.after.data());
    const reportId = context.params.documentId;
    const inventoryItemId = reportId;  // They are the same
    await db.doc(`/${inventoryCollection}/${inventoryItemId}`)
            .set({isCollected: isReportCollected}, { merge: true });
}

exports.updateInventoryOnReport = functions.firestore.document(docPath(constants.COLLECTIONS.TEST.REPORTS)).onWrite((change, context) => 
    updateIsCollectedOnReport(constants.COLLECTIONS.TEST.INVENTORY, change, context)
)

exports.updateInventoryOnReport = functions.firestore.document(docPath(constants.COLLECTIONS.PRODUCTION.REPORTS)).onWrite((change, context) => 
    updateIsCollectedOnReport(constants.COLLECTIONS.PRODUCTION.INVENTORY, change, context)
)