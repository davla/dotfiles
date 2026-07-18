--[[
    This script runs within imapfilter. It checks if I have received the email with the commuter card renewal receipt.
    If that's the case, it prints to STDOUT the commuter card expiration day, in '%d %B %Y' format, and exits with 0.
    If no email has been received, it exists with 1.

    {{@@ header() @@}}
--]]

local os = require("os")

options.info = false

local RENEWAL_SUBJECT = "Commuter Card Invoice"
local EXPIRATION_DATE_PATTERN = "Valid to: (%w+) (%d+), (%d%d%d%d)"

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
local expiration_month, expiration_day, expiration_year = renewal_mail_body:match(EXPIRATION_DATE_PATTERN)

print(table.concat({ expiration_day, expiration_month, expiration_year }, " "))

os.exit(0)
