case 'E':
    if (txtTotalForm) { txtTotalForm.className = "fieldinput_readonly"; txtTotalForm.disabled = true; }
    if (txtAggregateAmt) { txtAggregateAmt.className = "fieldinput_readonly"; txtAggregateAmt.disabled = true; }
    if (DeclarationDate) { DeclarationDate.className = "fieldinput_readonly"; DeclarationDate.disabled = true; }
    HighlightNote();
    // start of IR 26050092
    handleTaxYears();
    handleAckIncomeFieldsInEnquiry();
    // End of IR 26050092
    break;
    
    
    // start of IR 26050092
function handleAckIncomeFieldsInEnquiry() {
    var ackFields = ["AckNo1", "AckNo2"];
    var incFields = ["ReturnIncome1", "ReturnIncome2"];

    // --- AckNo fields: read-only; default "NA" only if backend left them empty ---
    for (var i = 0; i < ackFields.length; i++) {
        var el = window.document.getElementsByName(ackFields[i])[0];
        if (el) {
            el.disabled = true;
            el.className = "fieldinput_readonly";
            // Remove focus/blur handlers so defaults aren't cleared in enquiry
            el.onfocus = null;
            el.onblur  = null;
            // If the backend didn't send a value, show NA
            if (myTrim(el.value) == "") {
                el.value = "NA";
            }
        }
    }

    // --- ReturnIncome fields: read-only; default "0" only if backend left them empty ---
    for (var j = 0; j < incFields.length; j++) {
        var el2 = window.document.getElementsByName(incFields[j])[0];
        if (el2) {
            el2.disabled = true;
            el2.className = "fieldinput_readonly";
            el2.onfocus = null;
            el2.onblur  = null;
            el2.oninput = null;   // no decimal filtering needed in enquiry
            if (myTrim(el2.value) == "") {
                el2.value = "0";
            }
        }
    }
}
// End of IR 26050092