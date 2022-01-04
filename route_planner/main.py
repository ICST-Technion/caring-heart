import os
import sys

from inventory.factories.DbFactory import DbProvider
from inventory.interfaces import IDb
import webbrowser
from selenium import webdriver


def open_google_maps(url):
    webbrowser.open(url)


def js_code(addresses, infos):
    code = """let observer;let texts;let nodes = [...document.querySelectorAll('.tactile-searchbox-input')];
     let btns=document.querySelectorAll('.Zvyb8e-T3iPGc-Rsbfue-waypoint');"""
    for i, (address, info) in enumerate(zip(addresses, infos)):
        code += f"""nodes[{i}].insertAdjacentHTML('afterend', '{html_info(info, id=f'comment-{i}')}');\n"""
        code += f"""btns[{i}].addEventListener("click", function(){{
                    console.log('click {i}');
                    texts = nodes.map(node => node.parentElement.children[1].innerText);
                    texts.splice({i}, 1);
                    for(let i=0; i<nodes.length; i++){{
                        nodes[i].parentElement.children[1].innerText = texts[i];
                    }}
                    nodes.pop();
                }})\n"""
        # code += observer_deleted(f"nodes[{i}]", do=f"console.log('deleted', {i})")
    return code


def _resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.dirname(__file__)
    return os.path.join(base_path, relative_path)


def html_info(info: str, id):
    return f'<span id="{id}" style="position:absolute; left:5px; top: 10px; z-index:100">{info}</span>'


class RoutePlanner:
    def __init__(self, db_provider=lambda: DbProvider.GetDb('excel')):
        self._db: IDb = db_provider()

    @staticmethod
    def get_google_maps_directions_url(addresses, base_url='https://www.google.com/maps/dir/'):
        return base_url + '/'.join(addresses)

    def google_maps_directions(self, open_webrowser=True):
        uncollected_items = sorted(self._db.get('where', 'selection', '==', True),
                                   key=lambda item: item['neighborhood'])
        addresses = [item['address'] for item in uncollected_items]
        infos = [item['category'] for item in uncollected_items]
        print(f'infos, {infos}')
        code = js_code(addresses, infos)
        print(code)

        url = self.get_google_maps_directions_url(addresses)
        if open_webrowser:
            driver = webdriver.Chrome(_resource_path('./chromedriver.exe'))
            driver.get(url)
            driver.execute_script(code)
            user_choice = input('לחץ על כל מקש על מנת לסגור את החלון')
            # webbrowser.open(url)
        return url


if __name__ == '__main__':
    RoutePlanner().google_maps_directions()
