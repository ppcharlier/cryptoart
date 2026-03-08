import Vapor

func routes(_ app: Application) throws {
    let artController = ArtController()
    let galleryController = GalleryController()
    
    app.get(use: artController.index)
    app.get("art", use: artController.generateArt)
    app.get("past", use: artController.pastArt)
    
    // Hierarchical Route (Modern Fiction)
    app.get("europe", "belgium", ":series", ":character", use: artController.generateHierarchicalArt)
    
    // Mythological Route (Ancient Legends)
    app.get("myths", ":mythology", ":character", use: artController.generateHierarchicalArt)
    
    // Gallery Routes
    app.get("world", "galleries", use: galleryController.worldGalleries)
    app.get("randomgallery", use: galleryController.randomGallery)
    app.get("randommix", "univers", use: galleryController.randomMixUniverse)
    app.get("randommix", "universes", "myths", use: galleryController.randomMixMyths)
}
