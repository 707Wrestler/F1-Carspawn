let resourceName = ''; 


window.addEventListener('message', function(event) {
    if (event.data.type == "openMenu") {
        resourceName = event.data.resourceName;  
        document.getElementById('menu').style.display = 'block'; 
        document.body.classList.add('menu-open');
        populateVehicleList(event.data.vehicles); 
    } else if (event.data.type == "closeMenu") {
        document.getElementById('menu').style.display = 'none'; 
        document.body.classList.remove('menu-open');
    }
});


window.addEventListener('keydown', function(event) {
    if (event.key === "Escape") {  
        closeMenu();  
    }
});

function closeMenu() {
    document.getElementById('menu').style.display = 'none'; 
    document.body.classList.remove('menu-open');
    fetch(`https://${resourceName}/closeMenu`, {  
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(res => res.json()).then(data => {
        console.log('Menu closed', data);
    });
}


function populateVehicleList(vehicles) {
    const vehicleListElement = document.getElementById('vehicleList');
    vehicleListElement.innerHTML = ''; 

    vehicles.forEach(vehicle => {
        const li = document.createElement('li');
        li.textContent = vehicle.name;
        li.addEventListener('click', () => spawnVehicle(vehicle.name)); 
        vehicleListElement.appendChild(li);
    });
}


function spawnVehicle(vehicleName) {
    fetch(`https://${resourceName}/spawnVehicle`, {  
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ vehicleName: vehicleName })
    }).then(res => res.json()).then(data => {

    });
}





function setNuiFocus(focus) {
    fetch(`https://${GetParentResourceName()}/setNuiFocus`, {
        method: 'POST',
        body: JSON.stringify({ focus: focus })
    });
}


window.addEventListener('message', function(event) {
    if (event.data.type === 'openMenu') {
        setNuiFocus(true);
    }
});


window.addEventListener('message', function(event) {
    if (event.data.type === 'closeMenu') {
        setNuiFocus(false);
    }
});