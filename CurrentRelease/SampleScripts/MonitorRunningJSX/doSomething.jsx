//@targetengine Tgh1

var TGH = {};

TGH.state = {};
TGH.state.DOC_COUNT = 10;

var prvDocIdx = undefined;
for (var docIdx = 0; docIdx < TGH.state.DOC_COUNT + 1; docIdx++) {
    TGH.state.docIdx = docIdx;
    var docPath = File("~/Desktop/t" + docIdx + ".indd");
    if (prvDocIdx !== undefined) {
        var prvDocPath = File("~/Desktop/t" + prvDocIdx + ".indd");
        if (prvDocPath.exists) {
            prvDocPath.remove();
        }
    }

    if (docIdx < TGH.state.DOC_COUNT) {
        var doc = app.documents.add();
        var tf = doc.textFrames.add();

        doc.viewPreferences.horizontalMeasurementUnits = MeasurementUnits.MILLIMETERS;
        doc.viewPreferences.verticalMeasurementUnits = MeasurementUnits.MILLIMETERS;
        tf.geometricBounds = [10,10,110,110];
        tf.contents = "Hello world " + docIdx;

        doc.save(docPath);
        doc.close(SaveOptions.NO);
    }
    
    prvDocIdx = docIdx;    
}

