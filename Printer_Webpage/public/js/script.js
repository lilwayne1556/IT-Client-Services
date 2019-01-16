function addRow(printer, headers){
    // Start of table creation

    var row = document.createElement("tr");
    row.setAttribute("id", printer["Printer Name"]);

    //row.setAttribute("onclick", "moreInfo('"+printer["Printer Name"]+"')");
    row.setAttribute("onclick", "window.open('http://"+printer['Address']+"')");

    // Create each column
    headers.forEach(function(attribute){
        var attributeValue = printer[attribute];
        var col = document.createElement("td");
        var p = document.createElement("p");
        var level = parseInt(attributeValue*100);

        $(col).attr("data-title", attribute);
        if(isNaN(level)){
            $(col).text(attributeValue);
        } else {
            $(col).text(level + "%");
            if(level > 20){
                $(col).attr("class", "good");
            }
            else if( level > 5){
                $(col).attr("class", "okay");
            }
            else if(level > 0){
                $(col).attr("class", "bad");
            } else {
                $(col).attr("class", "gone");
            }
        }

        row.appendChild(col);
    });

    document.getElementById("printers").appendChild(row);
}

function moreInfo(printer){
    var url = new URL(window.location);
    url.searchParams.set("printer", encodeURI(printer));
    window.location = url;
}

function sortPrinters(printers, sortingAttr, clicked){
    printers.sort(function(a, b){
        var p1 = a[sortingAttr];
        var p2 = b[sortingAttr];
        if(p1 < p2){
            return -1;
        }
        else if(p1 > p2){
            return 1;
        }
        else {
            return 0;
        }
    });

    if(sortBy == sortingAttr && clicked){
        if(!reverseSort){
            reverseSortClicked = true;
            reverseSort = true;
            printers.reverse();
            document.getElementById(sortingAttr).innerHTML = sortingAttr + "<p class='arrow'>↑</p>";
        }
        else{
            reverseSortClicked = false;
            reverseSort = false;
            document.getElementById(sortingAttr).innerHTML = sortingAttr + "<p class='arrow'>↓</p>";
        }
    }
    else if(clicked) {
        reverseSort = false;
        document.getElementById(sortBy).innerText = sortBy;
        document.getElementById(sortingAttr).innerHTML = sortingAttr + "<p class='arrow'>↓</p>";
    }
    else if(reverseSort && reverseSortClicked){
        printers.reverse();
        document.getElementById(sortBy).innerText = sortBy;
        document.getElementById(sortingAttr).innerHTML = sortingAttr + "<p class='arrow'>↑</p>";
    }
    else {
        document.getElementById(sortingAttr).innerHTML = sortingAttr + "<p class='arrow'>↓</p>";
    }

    sortBy = sortingAttr;

    document.getElementById("printers").innerHTML = "";
    for(var i=0; i < badPrinters.length; i++){
        addRow(badPrinters[i], headers);
    }

    for(var i=0; i < printers.length; i++){
        addRow(printers[i], headers);
    }
}

function populatePrinters(){
    printersJSON = $.ajax({
        type: "GET",
        url: "data/printers.json",
        async: false,
        contentType: "application/json",
        dataType: "json"
    }).responseJSON;

    printers = [];
    badPrinters = [];
    $.each(printersJSON, function(key, value){
        if(typeof value["Black Toner"] !== "undefined"){
            printers.push(value);
        } else {
            badPrinters.push(value);
        }
    });
    if(url.search){
        // Printer specific information
    } else {
        // General view
        tr = document.createElement("tr");
        headers.forEach(function(attribute){
            header = document.createElement("th");
            $(header).text(attribute)
                .attr("onclick", "sortPrinters(printers, '"+attribute+"', "+true+")")
                .attr("id", attribute)
                .appendTo(tr);
        });

        document.getElementById("header").innerHTML = "";

        $(tr).appendTo("#header");

        sortPrinters(printers, sortBy, false);
    }

    setTimeout(populatePrinters, 30000);
}

var url = new URL(window.location);

// Get the list of printers from the print server and
// filter printers by ones we support, SCC & PRS prefixes
var printersJSON, printers, badPrinters, veralab;
var headers = ["Printer Name", "Black Toner", "Imaging Unit", "Maintenance Kit"];
var sortBy = "Black Toner";
var reverseSort = false;
var reverseSortClicked = false;

populatePrinters();
