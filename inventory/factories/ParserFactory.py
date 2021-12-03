
class ParserProvider(object):
    """Parser Factory
    """
    @staticmethod
    def GetParser(parser, *args, **kwargs):
        if parser is None or parser.lower() == "stub":
            from inventory.parser.StubParser import Parser
        elif parser.lower() == "mailparser":
            from inventory.parser.MailParser import Parser
        else:
            raise Exception(f"Unknown mail {parser}")
        return Parser(*args, **kwargs)
