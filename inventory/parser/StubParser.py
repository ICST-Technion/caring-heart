from inventory.interfaces.IParser import IParser


class Parser(IParser):

    def parse(self, text):
        columns = ["Name", "Address", "Street", "City", "Phone", "Description", "Category", "Date", "Comments", "Email"]
        return {columns[index]: item.strip() for index, item in enumerate( text.split('\n')[0].split(","))}
