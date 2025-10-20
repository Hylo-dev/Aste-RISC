struct TabCategoryItem: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let icon: String
    let creationModalities: [CreationModalityItem]
}
