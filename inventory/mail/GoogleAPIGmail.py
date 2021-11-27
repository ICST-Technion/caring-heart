import os
import email
import base64
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials

from inventory.interfaces.IMail import IMail


class Gmail(IMail):
    def __init__(self):
        self._scopes = ['https://www.googleapis.com/auth/gmail.readonly']
        path = os.path.dirname(os.path.realpath(__file__))
        self._history_filename = f'{path}\\history.list'
        self._cred_filename = f'{path}\\credentials.json'
        self._token_filename = f'{path}\\token.json'
        self._service = self._build_service()

    def _get_remote_id(self):
        last_msg = self._service.users().messages().list(userId='me', maxResults=1).execute()
        messages = last_msg.get('messages', [])
        if not messages:
            return None
        msg_id = messages[0]['id']
        msg = self._service.users().messages().get(userId='me', id=msg_id).execute()
        history_id = msg.get('historyId', None)
        return history_id

    def _get_local_id(self):
        if not os.path.exists(self._history_filename):
            return None
        with open(self._history_filename, 'r') as f:
            h_id = f.readline()
        return h_id.strip()

    def _set_local_id(self, id):
        with open(self._history_filename, 'w') as f:
            f.write(id)

    def _build_service(self):
        creds = None
        # The file token.json stores the user's access and refresh tokens, and is
        # created automatically when the authorization flow completes for the first
        # time.
        if os.path.exists(self._token_filename):
            creds = Credentials.from_authorized_user_file(self._token_filename, self._scopes)
        # If there are no (valid) credentials available, let the user log in.
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file(self._cred_filename, self._scopes)
                creds = flow.run_local_server(port=0)
            # Save the credentials for the next run
            with open(self._token_filename, 'w') as token:
                token.write(creds.to_json())

        return build('gmail', 'v1', credentials=creds)

    def _handle_message(self, msg):
        res = []
        msg_o = msg.get('message', {})
        msg_id = msg_o.get('id', None)
        if msg_id is not None:
            msg_ret = self._service.users().messages().get(userId='me', id=msg_id, format='raw').execute()
            msg_bytes = base64.urlsafe_b64decode(msg_ret['raw'])
            msg_from_str = email.message_from_string(msg_bytes.decode('utf-8'))
            for part in msg_from_str.walk():
                msg_from_str.get_payload()
                if part.get_content_type() == 'text/plain':
                    #res.append(base64.urlsafe_b64decode(part.get_payload()).decode("utf-8"))
                    res.append(part.get_payload(decode=True).decode("utf-8"))
        return "".join(res)

    def get_mail(self, **kwargs):
        res = []
        local_h_id = self._get_local_id()
        remote_h_id = self._get_remote_id()
        if remote_h_id is None or local_h_id == remote_h_id:
            return res
        # first sync - just grab the last history id and return
        if local_h_id is None:
            self._set_local_id(remote_h_id)
            return res

        results = self._service.users().history().list(userId='me', startHistoryId=local_h_id).execute()
        history = results.get('history', [])

        for rec in history:
            for msg in rec.get('messagesAdded', []):
                res.append(self._handle_message(msg))

        self._set_local_id(remote_h_id)
        return res


if __name__ == '__main__':
    for mail in Gmail().get_mail():
        print (mail)
