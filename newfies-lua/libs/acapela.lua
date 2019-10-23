--
-- acapela.lua - Lua wrapper for text-to-speech synthesis with Acapela
-- Copyright (C) 2012-2015 Arezqui Belaid <areski@gmail.com>
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation files
-- (the "Software"), to deal in the Software without restriction,
-- including without limitation the rights to use, copy, modify, merge,
-- publish, distribute, sublicense, and/or sell copies of the Software,
-- and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
-- BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local md5 = require "md5"
require "lfs"
require "cURL"


-- Check file exists and readable
function file_exists(path)
    local attr = lfs.attributes(path)
    if (attr ~= nil) then
        return true
    else
        return false
    end
end

--
-- Get an url and save result to file
--
function wget(url, outputfile)
    -- open output file
    f = io.open(outputfile, "w")
    local text = {}
    local function writecallback(str)
        f:write(str)
        return string.len(str)
    end
    local c = cURL.easy_init()
    -- setup url
    c:setopt_url(url)
    -- perform, invokes callbacks
    c:perform({writefunction = writecallback})
    -- close output file
    f:close()
    return table.concat(text,'')
end

--
-- URL Encoder
--
function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str
end

--
-- Acapela Class
--

local Acapela = {
    -- default field values
    ACCOUNT_LOGIN = 'EVAL_XXXX',
    APPLICATION_LOGIN = 'EVAL_XXXXXXX',
    APPLICATION_PASSWORD = 'XXXXXXXX',

    SERVICE_URL = 'http://vaas.acapela-group.com/Services/Synthesizer',
    LANGUAGE = 'EN',
    QUALITY = '22k',  -- 22k, 8k, 8ka, 8kmu
    DIRECTORY = '/tmp/',

    -- Properties
    filename = nil,
    cache = true,
    data = {},
    langs = {},
}

-- Meta information
Acapela._COPYRIGHT   = "Copyright (C) 2014-2015 Areski"
Acapela._DESCRIPTION = "Lua wrapper for text-to-speech synthesis with Acapela"
Acapela._VERSION     = "lua-acapela 0.3.1"


function Acapela:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

-- function Acapela:init(account_login, application_login, application_password, url, quality, directory)
--     -- constructor
--     self.ACCOUNT_LOGIN = account_login
--     self.APPLICATION_LOGIN = application_login
--     self.APPLICATION_PASSWORD = application_password
--     self.SERVICE_URL = url
--     self.QUALITY = quality
--     self.DIRECTORY = directory or ''
-- end


function Acapela:prepare(text, lang, gender, intonation)

    -- Available voices list
    -- http://www.acapela-vaas.com/ReleasedDocumentation/voices_list.php

    self.langs = {
        EN = {W = {NORMAL = 'lucy'}, M = {NORMAL = 'graham'}},
        US = {W = {NORMAL = 'karen'}, M = {NORMAL = 'ryan'}},
        ES = {W = {NORMAL = 'ines'}, M = {NORMAL = 'antonio'}},
        FR = {W = {NORMAL = 'alice'}, M = {NORMAL = 'antoine'}},
        PT = {W = {NORMAL = 'celia'}},
        BR = {W = {NORMAL = 'marcia'}},
    }

    -- Prepare Acapela TTS
    if string.len(text) == 0 then
        return false
    end
    lang = string.upper(lang)
    concatkey = text..'-'..lang..'-'..gender..'-'..intonation
    hash = md5.sumhexa(concatkey)

    key = 'acapela'..'_'..hash
    req_voice = self.langs[lang][gender][intonation]..self.QUALITY
    self.filename = key..'-'..lang..'.mp3'

    self.data = {
        cl_env = 'LUA',
        req_snd_id = key,
        cl_login = self.ACCOUNT_LOGIN,
        cl_vers = '1-30',
        -- req_err_as_id3 = 'yes',
        req_voice = req_voice,
        cl_app = self.APPLICATION_LOGIN,
        prot_vers = '2',
        cl_pwd = self.APPLICATION_PASSWORD,
        req_asw_type = 'STREAM',
        --req_text = text,
        req_text = '\\vct=100\\ \\spd=160\\ '..text,
        --req_text = 'Hello+how+are+you',
    }
end

function Acapela:set_cache(value)
    -- Enable Cache of file, if files already stored return this filename
    self.cache = value
end

function Acapela:run()
    -- Run will call acapela API and reproduce audio

    -- Check if file exists
    if self.cache and file_exists(self.DIRECTORY..self.filename) then
        return self.DIRECTORY..self.filename
    else
        --Get all the Get params and encode them
        get_params = ''
        for k, v in pairs(self.data) do
            if get_params ~= '' then
                get_params = get_params..'&'
            end
            get_params = get_params..tostring(k)..'='..url_encode(v)
        end

        print("HTTP CALL: "..self.SERVICE_URL..'?'..get_params, self.DIRECTORY..self.filename)
        wget(self.SERVICE_URL..'?'..get_params, self.DIRECTORY..self.filename)

        if file_exists(self.DIRECTORY..self.filename) then
            return self.DIRECTORY..self.filename
        else
            --Error
            return false
        end

    end
end

return Acapela
