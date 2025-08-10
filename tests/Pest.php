<?php

use Tests\TestCase;

/*
|--------------------------------------------------------------------------
| Test Case
|--------------------------------------------------------------------------
|
| This file configures the base Test Case for Pest. It will be applied to
| all tests in the given directories.
|
*/

uses(TestCase::class)->in('Feature', 'Unit');
