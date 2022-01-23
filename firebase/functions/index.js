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

//const spreadsheetId = "1KEnhldGfYakoIgibePV0pxbEiEr2kgRbj2RQyg3R51c";
const spreadsheetId = "1X1q6YAQdXoEmkUn2KhygDzswDlwZ8epW2NL3jSu1tj0";
//const spreadsheetId = "1TC2SMsINKsXbUpqb75Bytl9B2VV3O82Yq66Q0hhP-uk";
const documentPath = '/inventoryTest/{documentId}';

const serviceAccount = require("./serviceAccount.json");

const jwtClient = new google.auth.JWT({
    email: serviceAccount.client_email,
    key: serviceAccount.private_key,
    scopes: ["https://www.googleapis.com/auth/spreadsheets"],
});
const jwtAuthPromise = jwtClient.authorize();
const admin = require('firebase-admin');

admin.initializeApp();

exports.createSheets = functions.firestore.document(documentPath)
    .onCreate((snap, context) => {
        const data = snap.data();
        if (data.fromSheets){
            return snap.ref.set({ fromSheets: false}, {merge: true});
        }
        const values = getRowValues(data, context.params.documentId);
        return sheetAppendLine(values, getSheetName());
    });

function getRowValues(data, documentId) {
    const columnData = constants.FIELDS.map(field => format(field.name, data[field.name]) ?? '');
    const values = [[documentId, true, ...columnData]];
    return values;
}

async function sheetAppendLine(values, range) {
    await jwtAuthPromise;
    return sheets.spreadsheets.values.append(
        {
            auth: jwtClient,
            spreadsheetId: spreadsheetId,
            range: range,
            valueInputOption: "USER_ENTERED",
            insertDataOption: 'INSERT_ROWS',
            resource: {
                values: values,
            },
        },
        {}
    );
}

exports.updateSheets = functions.firestore.document(documentPath)
    .onUpdate(async (change, context) => {
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
        let formula = `=MATCH("${context.params.documentId}", ${getSheetName()}!A:A, 0)`;
        sheetsUpdate([[formula]], "LookUp_Sheet789!A1", "USER_ENTERED").then(( response) => {
            const line = response.data.updatedData.values[0][0];
            functions.logger.log(`Found line ${line}`);
            const values = getRowValues(data, context.params.documentId);
            functions.logger.log(`Col values are`, values);
            if (isNaN(line)){
                sheetAppendLine(values, getSheetName());
            }
            else{
                sheetsUpdate(values, `${getSheetName()}!A${line}:N${line}`, "USER_ENTERED");
            }
        });
    });

async function sheetsUpdate(values, range, valueInputOption) {
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
    date = timestamp.toDate();
    return `${date.getUTCDate()}/${date.getMonth()+1}/${date.getFullYear()}`;
}

function getSheetName() {
    return "Sheet1";
}