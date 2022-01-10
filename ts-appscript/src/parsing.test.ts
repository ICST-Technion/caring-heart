import { FORM_FIELDS, Item } from "./constants";
import { formValuesToItem } from "./parsing";

describe(formValuesToItem, () => {
    it('should match order of values param to order of formFields param + add false isCollected & isChecked fields', () => {
        const item: Item = {
            name: "dor",
            address: "",
            neighborhood: "",
            city: "",
            phone: "0501111111",
            category: "",
            description: "",
            date: new Date("1/2/1999"),
            comments: "",
            email: "",
            isChecked: false,
            isCollected: false
        }
        const values = [
            "2/1/1999 21:00:12", // Date: israel date -> US date 
            "", //"email", 
            "dor", // "name", 
            "", //"city",
            "",//"neighborhood", 
            "", //"address", 
            "0501111111", //"phone", 
            "", // "category", 
            "", //"description", 
            "", //"comments"
        ]
        expect(formValuesToItem<Item>(values, FORM_FIELDS)).toStrictEqual(item)
    });
});