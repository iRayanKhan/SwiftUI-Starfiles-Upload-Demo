//
//  ContentView.swift
//  SwiftUI-Starfiles-Upload-Demo
//
//  Created by Rayan Khan on 7/15/22.
//

import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
    @State var SelectFile = false
    @State var uploadInProgress = false
    @State var fileStatus : String  = "Starfiles File Upload Demo"
    @State var allowedFileType = UTType(filenameExtension: "ipa")
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text(" \(uploadInProgress ? "File Upload in Progress..." : fileStatus)")
                .font(.title)
      
            
            Button(action: {
               SelectFile = true
            }) {
                HStack {
                    Image(systemName: "\(uploadInProgress ? "arrow.clockwise.circle" : "arrow.up.square")")
                        .font(.headline)
                    Text(" \(uploadInProgress ? "Select a different file" : "Select File")")
                        .fontWeight(.semibold)
                        .font(.headline)
                }
                .padding()
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .bottomLeading))
                .cornerRadius(40)
                .fileImporter(isPresented: $SelectFile, allowedContentTypes: [allowedFileType!]) { result in
                            do {
                                let fileURL = try result.get()
                                fileURL.startAccessingSecurityScopedResource()
                                let FileData = try Data(contentsOf: fileURL)
                                let FileName = fileURL.lastPathComponent
                                uploadFile(paramName: "upload", FileName: FileName, File: FileData)
                            } catch {
                                print("Error")
                            }
                        }
            }
        }
    }
    
    //MARK: File upload function
    
    func uploadFile(paramName: String, FileName: String, File: Data) {
        uploadInProgress = true
       
        print("File Upload Debug:")
        print("File Upload in progress")
        print("FileName: " + FileName)
     
            let url = URL(string: "https://api.starfiles.co/upload/upload_file")
            let boundary = UUID().uuidString
            let session = URLSession.shared
            var urlRequest = URLRequest(url: url!)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            var data = Data()
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(FileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            data.append(File)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
                if error == nil {
                    do {
                        
                        let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                        if let json = jsonData as? [String: Any] {
                            print(json)
                            let      FileID = json["file"] as! String
                            uploadInProgress = false
                            let fileStatus = "File Id: " + FileID
                            
                            print("Got FileID:" + FileID)
                        }
                    }
                }
                
            }).resume()
        }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
