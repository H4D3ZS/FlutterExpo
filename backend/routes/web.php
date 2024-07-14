<?php

use Illuminate\Support\Facades\Route;
use SimpleSoftwareIO\QrCode\Facades\QrCode;
use App\Http\Controllers\AppController;


Route::get('/', function () {
    return view('welcome');
});


// QR CODE GENERATOR

Route::get('/app-code', [AppController::class, 'getAppCode'])->name('getAppCode');
Route::get('/generate-qr', [AppController::class, 'generateQrCode']);   