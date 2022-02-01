import Vapor

func routes(_ app: Application) throws {
    app.webSocket("ask") { request, ws in
        ws.onText { ws, text in
            print(text)
            let song = songs[Int.random(in: 0..<songs.count)]
            if let stringSong = try? JSONEncoder().encode(song) {
                print(String(data: stringSong, encoding: .utf8))
                ws.send(String(data: stringSong, encoding: .utf8)!)
            }
        }
    }
    
    app.get("song") { request -> Response in
        let song = songs[Int.random(in: 0..<songs.count)]
        if let stringSong = try? JSONEncoder().encode(song) {
            let httpResponse = Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(data: stringSong))
            print("SENDING: \(httpResponse)")
            return httpResponse
        }
        return .init(status: .notFound)
    }
}

let songs: [Song] = [
    Song(trackId: 1, artistName: "Maroon5", trackName: "Sad", collectionName: "Overexposed", previewUrl: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/75/1e/08/751e0834-1445-59d1-1281-f39a23e8822e/mzaf_11544983521414742565.plus.aac.p.m4a", artworkUrl100: "https://is5-ssl.mzstatic.com/image/thumb/Music124/v4/95/65/c7/9565c7e6-9ee5-1b9b-4d7e-97fa1d14e3ae/source/100x100bb.jpg"),
    Song(trackId: 2, artistName: "Pharrell Williams", trackName: "Happy", collectionName: "Happy (Oktoberfest Mix) - Single", previewUrl: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/46/5b/82/465b82ee-f7b1-fd5d-366a-eb164d809cb6/mzaf_6521804329652378308.plus.aac.p.m4a", artworkUrl100: "https://is5-ssl.mzstatic.com/image/thumb/Music124/v4/10/9d/99/109d99aa-0996-1dd8-a1ef-0408aa950968/source/100x100bb.jpg"),
    Song(trackId: 3, artistName: "Bon Jovi", trackName: "Always", collectionName: "Greatest Hits", previewUrl: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/e5/64/88/e5648808-21b9-1f8e-e85e-e9f70a7c4369/mzaf_2413721849656780368.plus.aac.p.m4a", artworkUrl100: "https://is2-ssl.mzstatic.com/image/thumb/Music124/v4/ed/55/44/ed5544ae-589f-62d7-5243-6bef48a0eadf/source/100x100bb.jpg"),
    Song(trackId: 4, artistName: "Bob Marley & The Wailers", trackName: "No Woman, No Cry", collectionName: "Legend (Deluxe Edition)", previewUrl: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/e7/f7/88/e7f7888f-bf7a-b01b-b7b6-8ac0ff2f1ffa/mzaf_7290019220663947549.plus.aac.p.m4a", artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music123/v4/63/96/ef/6396ef3c-b058-e999-96a9-e4ee7f03ddb2/source/100x100bb.jpg"),
    Song(trackId: 5, artistName: "Rihanna", trackName: "Stay (feat. Mikky Ekko)", collectionName: "Unapologetic (Deluxe Version)", previewUrl: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/9f/5d/f7/9f5df71a-c594-ff15-cb02-e7899339b4a4/mzaf_14052696123450148262.plus.aac.p.m4a", artworkUrl100: "https://is5-ssl.mzstatic.com/image/thumb/Music115/v4/4e/35/9d/4e359d1c-9c11-4f8f-c623-7d0711fa8e67/source/100x100bb.jpg"),
]

struct Song: Codable {
    var trackId: Int
    var artistName: String
    var trackName: String
    var collectionName: String
    var previewUrl: String
    var artworkUrl100: String
}


