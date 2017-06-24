function getHTML($logs){


$html=@"

<html>
<style>
#myInput {
    background-image: url('/searchicon.png'); /* Add a search icon to input */
    background-position: 10px 12px; /* Position the search icon */
    background-repeat: no-repeat; /* Do not repeat the icon image */
    width: 100%; /* Full-width */
    font-size: 16px; /* Increase font-size */
    padding: 12px 20px 12px 40px; /* Add some padding */
    border: 1px solid #ddd; /* Add a grey border */
    margin-bottom: 12px; /* Add some space below the input */
}

table {
    border-collapse: collapse; /* Collapse borders */
    width: 100%; /* Full-width */
    border: 1px solid #ddd; /* Add a grey border */
    font-size: 18px; /* Increase font-size */
}

 th,td {
    text-align: left; /* Left-align text */
    padding: 12px; /* Add padding */
}

tr {
    /* Add a bottom border to all table rows */
    border-bottom: 1px solid #ddd; 
}

th,tr:hover {
    /* Add a grey background color to the table header and on hover */
    background-color: #f1f1f1;
}
td { white-space:pre }

body{
font-family: "Segoe UI",Arial,sans-serif;
}

</style>


<body>

<div> 
<input type="text" id="myInput" onkeyup="myFunction()" placeholder="Search for tenant logs..">
"@





$html2=@"
</div>
</body>
<script>
function myFunction() {
  // Declare variables 
  var input, filter, table, tr, td, i;
  input = document.getElementById("myInput");
  filter = input.value.toUpperCase();
  table = document.getElementsByTagName("myTable");
  tr = document.getElementsByTagName("tr");

  // Loop through all table rows, and hide those who don't match the search query
  for (i = 1; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td")[0];
    if (td) {
      if (tr[i].innerHTML.toUpperCase().indexOf(filter) > -1) {
        tr[i].style.display = "";
      } else {
        tr[i].style.display = "none";
      }
    } 
  }
}

</script>

</html>
"@  



return  $html+$( $logs|ConvertTo-Html -Fragment )+$html2
}