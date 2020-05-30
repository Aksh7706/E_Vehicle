# E-Rath (E-Vehicle System IIT Indore)

This flutter app is meant for E-Vehicle tracking in IIT Indore. It works on the priciple of realtime geolocation tracking of the driver’s vehicles and showing the realtime location of all the active vehicles on the client side. It has two parts :<br/>
  1 ) **Users Part**<br/>
  2 ) **Driver's Console**

## Screens 

**HomeScreens** <br/> <br/>
![HomeScreen](https://firebasestorage.googleapis.com/v0/b/e-vehicle-project.appspot.com/o/WhatsApp%20Image%202020-05-29%20at%2011.21.25%20PM.jpg?alt=media&token=c6ec7d7e-c77e-4345-8172-96418272fdd6)&nbsp;&nbsp;&nbsp;![Caddy Driver's Login Screen](https://firebasestorage.googleapis.com/v0/b/e-vehicle-project.appspot.com/o/WhatsApp%20Image%202020-05-29%20at%2011.21.25%20PM%20(1).jpg?alt=media&token=4fd731e5-1389-4d01-b367-b4353f2e04d3)

**User Screen & Features** <br/> <br/>
![UserScreen](https://firebasestorage.googleapis.com/v0/b/e-vehicle-project.appspot.com/o/WhatsApp%20Image%202020-05-29%20at%208.02.33%20PM.jpg?alt=media&token=d316c250-522f-4aca-ac92-13fe46aa93c1)&nbsp;&nbsp;&nbsp;![UserScreen](https://firebasestorage.googleapis.com/v0/b/e-vehicle-project.appspot.com/o/WhatsApp%20Image%202020-05-29%20at%208.02.33%20PM%20(1).jpg?alt=media&token=cca6eb87-dbeb-4f6a-8054-5d7904f0ed54)
<br/><br/>
Features :

 - **Number of active vehicles** shown to user.
 - **Location** of the active vehicles **get dynamically updaded on user's screen** in **realtime**.
 - In case of **emergency**, user gets the feature to know which **vehicle** is **nearest** to it and to **make a call** to the vehicle driver for urgent help.
 - On tapping on any of the active vehicles, **vehicle and driver info** is shown to the user.
 - User can move the map camera position to his current location by pressing the current location button in the center.
 <br/> <br/>
 **Driver's Console & Features** <br/> <br/>
![Driver's Console](https://firebasestorage.googleapis.com/v0/b/e-vehicle-project.appspot.com/o/WhatsApp%20Image%202020-05-30%20at%2012.12.40%20AM%20(3).jpg?alt=media&token=5d933ef3-34e0-466e-8baa-6f9e1ec1adf0)&nbsp;&nbsp;![Driver's Console](https://firebasestorage.googleapis.com/v0/b/e-vehicle-project.appspot.com/o/WhatsApp%20Image%202020-05-30%20at%2012.12.40%20AM.jpg?alt=media&token=1bc1caff-ec0a-495d-a56e-44742c295654)&nbsp;&nbsp;![Driver's Console](https://firebasestorage.googleapis.com/v0/b/e-vehicle-project.appspot.com/o/WhatsApp%20Image%202020-05-30%20at%2012.12.40%20AM%20(2).jpg?alt=media&token=b6f50880-858b-4dd2-8722-369f6bfdfa06)&nbsp;&nbsp;![Driver's Console](https://firebasestorage.googleapis.com/v0/b/e-vehicle-project.appspot.com/o/WhatsApp%20Image%202020-05-30%20at%2012.12.40%20AM%20(1).jpg?alt=media&token=00a10609-971c-4020-82d2-e2e3e5895976)

<br/><br/>
Features :

 - **Driver Login**: Admin can login into the application using email and password auth as given by the admin..
 - **Registration**: Any user can register as driver but only the one approved by the Admin/Supervisor gets access to the application as driver. The approved driver gets a user email and password to login to his account.
 - **Chat Service**: Drivers are also provided with a chat service having a common chat room, so that the drivers can share some important information with each other and can also coordinate and plan their movements.
 - **View Active Vehicles** : The driver can also view other active vehicle’s location which gets dynamically updated at the database as soon as the location of that vehicle changes and is also updated at the drivers screen in realtime. The driver upon tapping on any of the active vehicle’s markers also gets the driver details who is currently driving that vehicle and can use the chat service to coordinate his movement in accordance with other drivers.
 - **Add-On Features** : Driver gets an interface to toggle the status of the vehicle, whether it is active or not. Upon marking the vehicle as active the driver is prompted with a dialog box in which he needs to select the destination where he is headed towards and also the vehicle no. of the current vehicle he is driving, for successfully marking the vehicle as active. Also, the driver/admin gets an interface to dynamically update the unoccupied number of seats in the vehicle and the total number of seats in the vehicle will be shown to users for enhancing user experience.
 <br/> <br/>




