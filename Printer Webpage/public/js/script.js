function addRow(printer, displayAttributes){
    // Start of table creation
    var row = document.createElement("tr");
    row.setAttribute("id", printer["Printer Name"]);
    row.setAttribute("onclick", "moreInfo('"+printer["Printer Name"]+"')");

    // Create each column
    displayAttributes.forEach(function(attribute){
        var attributeValue = printer[attribute];
        var col = document.createElement("td");
        var p = document.createElement("p");
        var level = parseInt(attributeValue);

        col.setAttribute("data-title", attribute);
        if(isNaN(level)){
            col.innerText = attributeValue;
        } else {
            col.innerText = level + "%";
            if(level > 20){
                col.setAttribute("class", "good");
            }
            else if( level > 5){
                col.setAttribute("class", "okay");
            }
            else if(level > 0){
                col.setAttribute("class", "bad");
            } else {
                col.setAttribute("class", "gone");
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

var url = new URL(window.location);

// Get the list of printers from the print server and
// filter printers by ones we support, SCC & PRS prefixes

var printers = {
    "SCC-Barlett" : {},"SCC-Bridge" : {},"SCC-Campbell" : {},"SCC-CBB" : {},
    "SCC-CCL" : {},"SCC-GIL Lobby" : {},"SCC-Lang" : {},"SCC-Lawther" : {},
    "SCC-MAU099E" : {},"SCC-MAU099D" : {},"SCC-Maucker-1" : {},"SCC-Mauker-2" : {},
    "SCC-PantherVillage" : {},"SCC-Redeker" : {},"SCC-Rider" : {},"SCC-Roth" : {},
    "SCC-SEC Lobby" : {},"SCC-Shull" : {},"SCC-Towers" : {},"SCC-WRC" : {}
};

if(url.searchParams.get("printer")){
	// Printer specific information
} else {
	// General view
	var displayAttributes = ["Printer Name", "Toner", "Imaging Unit", "Maintenance Kit Life"];

	tr = document.createElement("tr");
	displayAttributes.forEach(function(attribute){
		header = document.createElement("th");
		header.innerText = attribute;
		tr.appendChild(header);
	});
	document.getElementById("header").appendChild(tr);

	// Testing purposes only
	for(var printer in printers){
		printers[printer]["Printer Name"] = printer;
		printers[printer]["Toner"] = Math.floor(Math.random() * 100);
		printers[printer]["Imaging Unit"] = Math.floor(Math.random() * 100);
		printers[printer]["Maintenance Kit Life"] = Math.floor(Math.random() * 100);
		addRow(printers[printer], displayAttributes);
	}
}