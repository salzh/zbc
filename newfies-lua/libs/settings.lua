
--
-- Database connection settings
--
DBHOST = 'localhost'
DBNAME = 'newfies_dialer_db'
DBUSER = 'newfies_dialer_53606'
DBPASS = '6EMtA5TSQNMGpmcTbA20'
DBPORT = 5432

--
-- Select the TTS engine, value : flite, acapela, mstranslator
--
TTS_ENGINE = 'flite'

--
-- Acapela TTS Settings
--
ACCOUNT_LOGIN = 'EVAL_VAAS'
APPLICATION_LOGIN = 'EVAL_YYYYYYY'
APPLICATION_PASSWORD = 'XXXXXXXX'
SERVICE_URL = 'http://vaas.acapela-group.com/Services/Synthesizer'
QUALITY = '22k'  -- 22k, 8k, 8ka, 8kmu
ACAPELA_GENDER = 'W'
ACAPELA_INTONATION = 'NORMAL'
ACAPELA_LANG = 'EN'

--
-- Microsoft Translator TTS Settings
--
CLIENT_ID = 'XXXXXXXXXXXX'
CLIENT_SECRET = 'YYYYYYYYYYYYYY'
MSTRANSLATOR_LANG = 'EN'
