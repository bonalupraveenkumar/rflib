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
@IsTest
@SuppressWarnings('PMD.ClassNamingConventions')
public class rflib_MockTriggerConfigQueryLocator implements rflib_TriggerManager.ITriggerConfigurationQueryLocator {
    
    public final String expectedObjectType;
    public final String expectedTriggerEvent;
    
    private final List<rflib_Trigger_Configuration__mdt> configRecords;
    
    public rflib_MockTriggerConfigQueryLocator(rflib_Trigger_Configuration__mdt configRecord, String expectedObjectType, String expectedTriggerEvent) {
        this(new List<rflib_Trigger_Configuration__mdt>{ configRecord }, expectedObjectType, expectedTriggerEvent);
    }

    public rflib_MockTriggerConfigQueryLocator(List<rflib_Trigger_Configuration__mdt> configRecords, String expectedObjectType, String expectedTriggerEvent) {
        this.configRecords = configRecords;
        this.expectedObjectType = expectedObjectType;
        this.expectedTriggerEvent = expectedTriggerEvent;
    }

    public List<rflib_Trigger_Configuration__mdt> getRecords(String objectType, String triggerEvent) {
        System.assertEquals(expectedObjectType, objectType, 'Unexpected object type');
        System.assertEquals(expectedTriggerEvent, triggerEvent, 'Unexpected trigger event');

        return configRecords;
    }
}
