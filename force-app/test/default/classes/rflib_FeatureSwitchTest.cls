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
@isTest
@SuppressWarnings('PMD.ClassNamingConventions')
private class rflib_FeatureSwitchTest {
    
    private static final String USER_SWITCH = 'FeatureSwitch1';
    private static final String PROFILE_SWITCH = 'FeatureSwitch2';
    private static final String GLOBAL_SWITCH = 'FeatureSwitch3';
    private static final String NON_EXISTING_FEATURE_SWITCH = 'DoesNotExist';

    private static final User USER = rflib_UserFactory.insertAndRetrieve('John', 'Smith', 'Standard User');

    private static void setup() {
        rflib_FeatureSwitch.featureSwitches = new Map<String,Map<String,Boolean>> {
            USER_SWITCH => new Map<String,Boolean> {
                'john.smith@rflib.com' => true,
                'Standard User' => false,
                rflib_FeatureSwitch.GLOBAL_SCOPE => false
            },

            PROFILE_SWITCH => new Map<String,Boolean> {
                'Standard User' => true,
                rflib_FeatureSwitch.GLOBAL_SCOPE => false
            },

            GLOBAL_SWITCH => new Map<String,Boolean> {
                rflib_FeatureSwitch.GLOBAL_SCOPE => true
            }
        };
    }

    @IsTest
    private static void testUserSwitch() {
        setup();

        System.runAs(USER) {
           System.assertEquals(true, rflib_FeatureSwitch.isTurnedOn(USER_SWITCH));
           System.assertEquals(false, rflib_FeatureSwitch.isTurnedOff(USER_SWITCH));
        }
    }


    @IsTest
    private static void testProfileSwitch() {
        setup();

        System.runAs(USER) {
           System.assertEquals(true, rflib_FeatureSwitch.isTurnedOn(PROFILE_SWITCH));
           System.assertEquals(false, rflib_FeatureSwitch.isTurnedOff(PROFILE_SWITCH));
        }
    }

    @IsTest
    private static void testGlobalSwitch() {
        setup();

        System.runAs(USER) {
           System.assertEquals(true, rflib_FeatureSwitch.isTurnedOn(GLOBAL_SWITCH));
           System.assertEquals(false, rflib_FeatureSwitch.isTurnedOff(GLOBAL_SWITCH));
        }
    }

    @IsTest
    private static void testNonExistingSwitch() {
        setup();

        System.runAs(USER) {
           System.assertEquals(false, rflib_FeatureSwitch.isTurnedOn(NON_EXISTING_FEATURE_SWITCH));
           System.assertEquals(true, rflib_FeatureSwitch.isTurnedOff(NON_EXISTING_FEATURE_SWITCH));
        }
    }
}