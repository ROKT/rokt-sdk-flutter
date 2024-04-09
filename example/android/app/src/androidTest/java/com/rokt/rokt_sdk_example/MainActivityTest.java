// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.rokt.rokt_sdk_example;
import androidx.test.core.app.ActivityScenario;
import androidx.test.ext.junit.runners.AndroidJUnit4;


import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/** Unit tests for {@link EspressoFlutter}. */
@RunWith(AndroidJUnit4.class)
public class MainActivityTest {

  @Before
  public void setUp() throws Exception {
    ActivityScenario.launch(MainActivity.class);
  }

  @Test
  public void performTripleClick() {

  }
}
