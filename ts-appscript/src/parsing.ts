import { CellValue, Item, UnparsedItem } from "./constants";
import { zip } from "./utils";
import { DataConvertor, convertFormsValues } from "./formSubmit";


export function formValuesToItem<ItemType>(values: CellValue[], formFields: string[], dc: DataConvertor = convertFormsValues): ItemType {
  let item = Object.fromEntries(zip(formFields, values));
  for (const field of Object.keys(dc)) {
    item[field] = dc[field](item[field]);
  }
  return { ...item, isCollected: false, isChecked: false } as unknown as ItemType;
}
