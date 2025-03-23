--[[
    This script runs within imapfilter. It checks if I have received the email with the monthly pass renewal receipt.
    If that's the case, it prints to STDOUT the day when the renewal happened, in YYYY-MM-DD format, and exits with 0.
    If no email has been received, it exists with 1.

    {{@@ header() @@}}
--]]

local os = require("os")

options.info = false

local RENEWAL_SUBJECT = "Automatisk fornyelse af periode på dit pendlerkort"
local RENEWAL_DATE_PATTERN = "<span style=.->(%d%d)-(%d%d)-(%d%d%d%d)</span>"

local get_email_at = function(emails, index)
    local mailbox, uid = table.unpack(emails[index])
    return mailbox[uid]
end

local account = IMAP({
    server = "{{@@ emails.main.server.name @@}}",
    username = "{{@@ emails.main.address @@}}",
    password = [[$MAIN_EMAIL_PASSWORD]],
})

local unread_renewal_mails = account.INBOX:is_unseen():contain_subject(RENEWAL_SUBJECT)
if #unread_renewal_mails == 0 then
    os.exit(1)
end

local renewal_mail_body = get_email_at(unread_renewal_mails, 1):fetch_body()
local renewal_day, renewal_month, renewal_year = renewal_mail_body:match(RENEWAL_DATE_PATTERN)

print(table.concat({ renewal_year, renewal_month, renewal_day }, "-"))

os.exit(0)
