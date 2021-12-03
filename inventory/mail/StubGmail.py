from inventory.interfaces.IMail import IMail


class Gmail(IMail):
    def get_mail(self, **kwargs):
        return ["Name1 , Address1 ,  Street1, City1, Phone1, Description1, Category1, Date1, Comments1, Email1"]