// start of IR 26050092
function handleAckIncomeFieldsInEnquiry() {
    var ackNo1 = window.document.getElementsByName("AckNo1")[0];
    var ackNo2 = window.document.getElementsByName("AckNo2")[0];
    var retInc1 = window.document.getElementsByName("ReturnIncome1")[0];
    var retInc2 = window.document.getElementsByName("ReturnIncome2")[0];

    // --- AckNo1 ---
    if (ackNo1) {
        ackNo1.disabled = true;
        ackNo1.className = "fieldinput_readonly";
        ackNo1.onfocus = null;
        ackNo1.onblur  = null;
        if (ackNo1.removeAttribute) {
            ackNo1.removeAttribute("onfocus");
            ackNo1.removeAttribute("onblur");
        }
        if (myTrim(ackNo1.value) == "") ackNo1.value = "NA";
    }

    // --- AckNo2 ---
    if (ackNo2) {
        ackNo2.disabled = true;
        ackNo2.className = "fieldinput_readonly";
        ackNo2.onfocus = null;
        ackNo2.onblur  = null;
        if (ackNo2.removeAttribute) {
            ackNo2.removeAttribute("onfocus");
            ackNo2.removeAttribute("onblur");
        }
        if (myTrim(ackNo2.value) == "") ackNo2.value = "NA";
    }

    // --- ReturnIncome1 ---
    if (retInc1) {
        retInc1.disabled = true;
        retInc1.className = "fieldinput_readonly";
        retInc1.onfocus = null;
        retInc1.onblur  = null;
        retInc1.oninput = null;
        if (retInc1.removeAttribute) {
            retInc1.removeAttribute("onfocus");
            retInc1.removeAttribute("onblur");
            retInc1.removeAttribute("oninput");
        }
        if (myTrim(retInc1.value) == "") retInc1.value = "0";
    }

    // --- ReturnIncome2 ---
    if (retInc2) {
        retInc2.disabled = true;
        retInc2.className = "fieldinput_readonly";
        retInc2.onfocus = null;
        retInc2.onblur  = null;
        retInc2.oninput = null;
        if (retInc2.removeAttribute) {
            retInc2.removeAttribute("onfocus");
            retInc2.removeAttribute("onblur");
            retInc2.removeAttribute("oninput");
        }
        if (myTrim(retInc2.value) == "") retInc2.value = "0";
    }
}
// End of IR 26050092
