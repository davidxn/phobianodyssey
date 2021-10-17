<?php
print ("This will only work with the Google API downloaded, and the src and vendor folders in the same folder as this script!" . PHP_EOL);
require __DIR__ . '/vendor/autoload.php';

$spreadsheetId = '1ldZ0EXH_GIozUMwVQcZHxcjAIx-r8NCNp4m_1ixl9tg';
$rgbMap = [
    '255 255 255' => '0',
    '217 234 211' => '0',
    '147 196 125' => '9',
    '255 229 153' => '11',
    '191 144 255' => '20', //255 is a miscalculation here but who cares!
];

if (php_sapi_name() != 'cli') {
    throw new Exception('This application must be run on the command line.');
}

/**
 * Returns an authorized API client.
 * @return Google_Client the authorized client object
 */
function getClient()
{
    $client = new Google_Client();
    $client->setDeveloperKey('AIzaSyBAeP8AD9sHcXa5zzGlLp2vls0sDqHTkKY');
    return $client;
}

// Get the API client and construct the service object.
$client = getClient();
$service = new Google_Service_Sheets($client);
$mapSheets = [1, 2, 3, 4, 5, 6, 7, 8, 9];

$fileMonsterParties = "../../pk3/MPARTY";
$fileMonsterPopulations = "../../pk3/MPOPUL";
$fileSquareData = "../../pk3/SQUAREDT";

$monsterParties = [];
$monsterPopulations = [];
$squareData = [];

//Get monster party information
$results = $service->spreadsheets_values->get($spreadsheetId, 'MonsterParty!A2:L');
$parties = $results->getValues();

foreach($parties as $partyData) {
    $monstersThisParty = [];
    for ($i = 2; $i <= 11; $i++) {
        if (isset($partyData[$i])) {
            $monstersThisParty[] = ($partyData[$i] ?: 'NONE');
        } else {
            $monstersThisParty[] = 'NONE';
        }
    }
    $monsterParties[] = $partyData[0] . "," . str_replace(" ", "_", $partyData[1]) . "," . join(",", $monstersThisParty) . "\n";
}

file_put_contents($fileMonsterParties, $monsterParties);

//Get monster populations
$results = $service->spreadsheets_values->get($spreadsheetId, 'MonsterPartyGroup!A1:L');
$parties = $results->getValues();

foreach($parties as $partyData) {
    $monstersThisParty = [];
    for ($i = 1; $i <= 10; $i++) {
        if (isset($partyData[$i])) {
            $monstersThisParty[] = $partyData[$i];
        }
    }
    $monsterPopulations[] = $partyData[0] . "=" . join(",", $monstersThisParty) . "\n";
}

file_put_contents($fileMonsterPopulations, $monsterPopulations);

$results = $service->spreadsheets_values->get($spreadsheetId, 'MonsterParty!B1:L');


//Now interpret the map data
foreach ($mapSheets as $mapSheetNum) {
    try {
        $sheet = $service->spreadsheets->get($spreadsheetId, ['includeGridData' => true, 'ranges' => 'Floor' . $mapSheetNum . '!A1:T20', 'fields' => 'sheets/data/rowData/values/effectiveFormat/backgroundColor,sheets/data/rowData/values/formattedValue']);
    }
    catch (Google\Service\Exception $e) {
        continue;
    }

    $squareNumber = 11900;
    if (!$sheet['sheets']) {
        continue;
    }
    foreach ($sheet['sheets']['0']['data']['0']['rowData'] as $rowData) {
        foreach ($rowData['values'] as $cellData) {
            $bgProperties = $cellData['effectiveFormat']['backgroundColor'] ?? [];
            $bgColor = ((round(($bgProperties['red']   ?? 1) * 255))) . ' ' .
                       ((round(($bgProperties['green'] ?? 1) * 255))) . ' ' .
                       ((round(($bgProperties['blue']  ?? 1) * 255)));
                       if (!isset($rgbMap[$bgColor])) {
                           echo("WARNING: Don't know what danger level " . $bgColor . " is! Will be 0");
                       }
            $dangerLevel = $rgbMap[$bgColor] ?? 0;
            $monsterPopulation = $cellData['formattedValue'] ?? 0;
            if ($monsterPopulation) {
                $squareData[] = "MP" . "-" . $mapSheetNum . '-' . $squareNumber . "=" . ($cellData['formattedValue'] ?? 0) . "\n";
            }
            if ($dangerLevel) {
                $squareData[] = "DN" . "-" . $mapSheetNum . '-' . $squareNumber . "=" . $dangerLevel . "\n";
            }
            $squareNumber++;
        }
        $squareNumber -= 120;
    }
}

file_put_contents($fileSquareData, $squareData);
