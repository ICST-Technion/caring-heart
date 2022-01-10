import { FORM_FIELDS, Item } from "./constants"
import { formDateStringToDate } from "./formSubmit"
import { formValuesToItem } from "./parsing"


describe(formDateStringToDate, () => {
    it('should only account for the date (ignore hour after space) and accept a format of dd/mm/yyyy for the date', () => {
        const monthIndex = 1 
        expect(formDateStringToDate('27/2/1999 23:00:00')).toStrictEqual(new Date(1999, monthIndex, 27))
    })
})