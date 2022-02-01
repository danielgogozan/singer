# singer
*Singer* app fetches songs from itunes providing search, download and listen functionalities. 

# purpose
The app offers a comprehensible example of how to:
- use **Data Task** and **Download Task** (of URLSession)
- use **FileManager** in order to save a song to a file
- **download, pause, resume or cancel** a Download Task
- use **Operations** for network request
- solve concurrency issues using **Async Operation**
- **chain operations** and how to enable communication between them using adapter pattern or protocols *(see SongViewModel.swift)*

The UI was built only by code.
The *SingerServer* is a server built using *Vapor* and it is used only for the "Discover" tab of the app.

# explore

![App flow](https://i.ibb.co/fv0dK1N/singer-screens.jpg)
