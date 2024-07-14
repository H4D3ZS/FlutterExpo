<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use SimpleSoftwareIO\QrCode\Facades\QrCode;


class AppController extends Controller
{
    //

     public function getAppCode()
    {
        // Assuming you have your Dart files stored in storage
        // $dartCode = file_get_contents(storage_path('app/my_flutter_app.dart'));
       $dartCode = file_get_contents('/Users/hades/Desktop/Flaredev_Framework/mobile/lib/main.dart');


        return response()->json(['code' => $dartCode]);
    }

    public function generateQrCode()
    {
        $url = route('getAppCode'); // Route to the getAppCode method
        $qrCode = QrCode::size(300)->generate($url);
        return response($qrCode)->header('Content-type', 'image/png');
    }

}
