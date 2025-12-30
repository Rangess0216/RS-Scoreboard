window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === "toggle") {
        let board = document.getElementById("scoreboard");
        if (data.state) {
            board.style.display = "flex";
        } else {
            board.style.display = "none";
        }
    } 

    else if (data.action === "update") {
        updateData(data.id, data.players, data.police, data.ambulance, data.mechanic, data.doj);
    }
});

function updateData(id, players, police, ambulance, mechanic, doj) {
    document.getElementById("my-id").innerText = id;
    document.getElementById("players").innerText = players;
    document.getElementById("police").innerText = police;
    document.getElementById("ambulance").innerText = ambulance;
    document.getElementById("mechanic").innerText = mechanic;
    document.getElementById("doj").innerText = doj;
}