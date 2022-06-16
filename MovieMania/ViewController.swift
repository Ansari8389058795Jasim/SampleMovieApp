//
//  ViewController.swift
//  MovieMania
//
//  Created by Jassi on 6/16/22.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var moviePic: UIImageView!
}

class ViewController: UIViewController, UISearchBarDelegate{

    @IBOutlet var searchView: UIView!
    @IBOutlet var searchBar: UISearchBar?
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var movieGridView: UICollectionView!
    let reuseIdentifier = "MyCollectionViewCell"
    var moviesArray = [JSON]()
    var pageNo: Int = 1
    var totalRecord: Int = Int()
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /* Start Search Bar */
        searchView.roundedShapeView()
        navigationController?.navigationBar.tintColor = UIColor.black
        searchView?.layoutIfNeeded()
        searchBar?.backgroundColor = UIColor.clear
        searchBar?.backgroundImage = UIImage()
        searchBar?.isTranslucent = true
        searchBar?.placeholder = "Search..."
        searchBar?.tintColor = UIColor.black
        searchBar?.delegate = self
         /* End Search Bar */
        btnSearch.roundedShapeView()
        movieGridView.dataSource = self
        movieGridView.delegate = self
    }
    
    func searchBar(_ searchBarEdit: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        commonMethod()
    }
    
    @IBAction func searchMovie(_ sender: UIButton){
        commonMethod()
    }
    
    func commonMethod(){
        moviesArray.removeAll()
        searchBar!.resignFirstResponder()
        if !(searchBar?.text!.isEmpty)! {
            callMovieAPI(pageNo: 1, search_text: (searchBar?.text)!)
        }else{
            SharedFunctions.showAlertDialog(controller: self,title: "Error", message: "Empty field not allowed.", options: "Ok") { (option) in
                switch(option) {
                case 0:
                    break
                default:
                    break
                }
            }
        }
    }
    
    func callMovieAPI(pageNo: Int, search_text: String){
        if Connectivity.isConnectedToInternet {
            WSHome(page_no: pageNo, search_text: search_text)
        }else{
            SharedFunctions.showAlertDialog(controller: self,title: "Connection Error", message: "No Internet Connection", options: "Retry", "Cancel") { (option) in
                switch(option) {
                case 0:
                    self.callMovieAPI(pageNo: pageNo, search_text: search_text)
                    break
                case 1:
                    break
                default:
                    break
                }
            }
        }
    }
    
    func WSHome(page_no: Int, search_text: String){
        ActivityIndicator().showHudProgress()
        let tempURL = "http://www.omdbapi.com/?apikey=b9bd48a6&s=\(search_text)&type=movie&page=\(page_no)"
        let URL = tempURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        AF.request(URL!, method: .get).responseJSON { (response) in
            ActivityIndicator().hideHudProgress()
            switch response.result {
            case .success:
                do {
                    let json = try JSON(data: response.data!)
                    if json["Response"].string == "True" {
                        //self.moviesArray = json["Search"].array!
                        self.moviesArray.append(contentsOf: json["Search"].array!)
                        self.totalRecord = Int(json["totalResults"].string!) ?? 0
                        self.movieGridView.dataSource = self
                        self.movieGridView.delegate = self
                        self.movieGridView.reloadData()
                    }else{
                        self.movieGridView.reloadData()
                        SharedFunctions.showAlertDialog(controller: self,title: "Oops", message: json["Error"].string!, options: "Ok") { (option) in
                            switch(option) {
                            case 0:
                                break
                            default:
                                break
                            }
                        }
                    }
                } catch {
                   print(error)
                   // or display a dialog
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    // tell the collection view how many cells to make
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.moviesArray.count
        }
        
        // make a cell for each cell index path
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell
            cell.myLabel.text = self.moviesArray[indexPath.row]["Title"].string
            let imageURL = self.moviesArray[indexPath.row]["Poster"].string
            if var strImage: String = imageURL {
                if strImage != "" {
                    strImage = strImage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    cell.moviePic?.sd_setImage(with: URL(string: strImage ), placeholderImage: UIImage(named: "movie_placeholder"))
                }else{
                    cell.moviePic?.image = UIImage(named:"movie_placeholder")
                    cell.moviePic?.contentMode = .redraw
                }
            }else{
                cell.moviePic?.image = UIImage(named:"movie_placeholder")
                cell.moviePic?.contentMode = .redraw
            }
            return cell
        }
        
        // MARK: - UICollectionViewDelegate protocol
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // handle tap events
            //print("You selected cell #\(indexPath.item)!")
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            let itemWidth = (collectionView.bounds.width-30)/2
            let itemHeight = itemWidth*1.5
            return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = moviesArray.count - 1
        print(indexPath.row)
        if indexPath.row == lastElement {
            if(moviesArray.count<totalRecord){
                pageNo = pageNo + 1
                callMovieAPI(pageNo: pageNo, search_text: (searchBar?.text)!)
            }
        }
    }
}

extension UIView{
    func roundedShapeView(){
        self.layer.cornerRadius = 10
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.5)
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 2
        self.layer.shadowRadius = 5
    }
}
