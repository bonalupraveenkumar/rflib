/*
 * Copyright (c) 2019 Johannes Fischer <fischer.jh@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of mosquitto nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @group Logger
 * @description Trigger event handler that will send out an email to the Apex Email Notification list.
 *              Please make sure to set the Org Wide Email Sender Address in the Logger Custom Settings
 *              or the email will note be sent. This is due to the fact that Platform Event based triggers
 *              are executed by the System user. 
 */ 
@SuppressWarnings('PMD.ClassNamingConventions')
public without sharing class rflib_EmailLogEventHandler implements rflib_ITriggerHandler {

    private static final rflib_Logger LOGGER = rflib_DefaultLogger.createFromCustomSettings('rflib_EmailLogEventHandler');

    private static final String PLAIN_TEXT_MESSAGE = 'A Log Event was created by {0}.\nContext: {1}\nLog Messages: {2}';
    private static final String HTML_MESSAGE = '<h2>A Log Event was created by {0}.</h2><h3>Context: {1}</h3><p><b>Log Messages:</b> {2}</p>';

    private final Boolean useOrgWideEmailAddress;
    private final List<ApexEmailNotification> apexEmailNotifications;
    private final rflib_Logger_Settings__c loggerSettings;

    public rflib_EmailLogEventHandler() {
        this([SELECT Email, UserId FROM ApexEmailNotification], true, rflib_Logger_Settings__c.getInstance());
    }

    @TestVisible
    private rflib_EmailLogEventHandler(List<ApexEmailNotification> apexEmailNotifications, Boolean useOrgWideEmailAddress, rflib_Logger_Settings__c loggerSettings) {
        this.apexEmailNotifications = apexEmailNotifications;
        this.useOrgWideEmailAddress = useOrgWideEmailAddress;
        this.loggerSettings = loggerSettings;
    }

    public void run(rflib_TriggerManager.Args args) {
        LOGGER.info('run() invoked');
        if (apexEmailNotifications.size() == 0) {
            LOGGER.info('No Apex email notifications found');
            return;
        }

        List<String> emailAddresses = new List<String>();
        List<Id> userIds = new List<Id>();

        for (ApexEmailNotification apexEmail : apexEmailNotifications) {
            if (String.isNotEmpty(apexEmail.Email)) {
                emailAddresses.add(apexEmail.Email);
            }

            if (String.isNotEmpty(apexEmail.UserId)) {
                userIds.add(apexEmail.UserId);
            }
        }

        emailAddresses.addAll(getEmailAddressesForUsers(userIds));

        LOGGER.info('Recipients of log event: ' + String.join(emailAddresses, ','));

        List<rflib_Log_Event__e> events = (List<rflib_Log_Event__e>) args.newRecords;
        Integer numEmailToSend = Math.min(events.size(), 10);

        LOGGER.info('Emails to be sent = ' + numEmailToSend);
        for (Integer i = 0; i < numEmailToSend; i++) {
            rflib_Log_Event__e evt = events[i];
            if (matchesConfiguredLogLevel(evt)) {
                sendMessage(emailAddresses, evt);
            }
        }
    }

    public void onConsecutiveRun(rflib_TriggerManager.Args args, Integer numInvocation) {
        // do nothing
    }

    private Boolean matchesConfiguredLogLevel(rflib_Log_Event__e evt) {
        return rflib_LogLevel.fromString(loggerSettings.Email_Log_Level__c).
            encompasses(rflib_LogLevel.fromString(evt.Log_Level__c));
    }

    private List<String> getEmailAddressesForUsers(List<Id> userIds) {
        List<String> result = new List<String>();
        for (User u : [SELECT Email FROM USER WHERE Id IN :userIds]) {
            result.add(u.Email);
        }
        
        return result;
    }

    private Id getOrgWideEmailAddressId() {
        rflib_Logger_Settings__c settings = rflib_Logger_Settings__c.getOrgDefaults();
        return [SELECT Id FROM OrgWideEmailAddress WHERE Address = :settings.Org_Wide_Email_Sender_Address__c].Id;
    }

    private void sendMessage(List<String> toAddresses, rflib_Log_Event__e event) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(toAddresses);

        if (useOrgWideEmailAddress) {
            mail.setOrgWideEmailAddressId(getOrgWideEmailAddressId());
        }

        mail.setSubject('A Log Event Occurred');
        mail.setPlainTextBody(String.format(PLAIN_TEXT_MESSAGE, new String[] { event.CreatedById, event.Context__c, event.Log_Messages__c  }));
        mail.setHtmlBody(String.format(HTML_MESSAGE, new String[] { event.CreatedById, event.Context__c, event.Log_Messages__c.replaceAll('(\\r|\\n)+', '<br />')  }));

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
