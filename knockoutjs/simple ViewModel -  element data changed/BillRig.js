//*************************************************************************************
// Page Save and Load
//*************************************************************************************
var hasLoadedDetails = false; //flag to stop data-bind click from happening on pageload
var tempAccountProfileServiceID = null;
var servicesViewModel = null;


function loadPage() {
    var paramObject = new Object();
    requestJSONInfo("getTTVServiceDetails", paramObject); // send request
}


function ServicesViewModel() {
    var self = this;
    
    self.Services = ko.observableArray([]);

    // Operations
    self.addServices = function(data) {
        self.Services.push(data);
    };

    self.updateService = function(serviceID) {
        for(x = 0; x < self.Services().length; x++) {
            self.Services()[x].Active = false;
            if(self.Services()[x].ServiceID == serviceID) {
                self.Services()[x].Active = true;
            }
        }
    };

    self.refresh = function() {
        var data = self.Services().slice(0);
        self.Services([]);
        self.Services(data);
    };
}


function getTTVServiceDetails(response) {
    hasLoadedDetails = false;
    
    for(x = 0; x < response.data.Services.length; x++) {
        if(response.data.Services[x].AccountProfileServiceID != null) tempAccountProfileServiceID = response.data.Services[x].AccountProfileServiceID;
    }

    servicesViewModel = new ServicesViewModel();
    for(y = 0; y < response.data.Services.length; y++) {
        servicesViewModel.addServices(response.data.Services[y]);
    }

    ko.applyBindings(servicesViewModel);
    hasLoadedDetails = true;

    //requestAccountProfileServices();
    TTVServices = response.data.Services;  //might have to remove
}


function updateTTVAccountProfileService(ServiceID) {
	if(hasLoadedDetails) {
        servicesViewModel.updateService(ServiceID);
        servicesViewModel.refresh();

		var paramObject = new Object();
		paramObject.data = {};
		paramObject.data.AccountProfileServiceID = tempAccountProfileServiceID; 
		paramObject.data.AccountProfileID = userProfile.ProfileID;
		paramObject.data.ServiceID = ServiceID;
		paramObject.data.Active = true;
		console.log(JSON.stringify(paramObject));
		requestJSONInfo("setAccountProfileService", paramObject); // send request
	}
}


function setAccountProfileService(response) {
//  ignore this callback
}