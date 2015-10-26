function (doc, meta) {
    if(doc.type == "rocket"){
        emit(doc.name, null);
    }
}