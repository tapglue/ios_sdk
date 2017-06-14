//
//  Comment.swift
//  Tapglue
//
//  Created by Onur Akpolat on 28/07/16.
//  Copyright © 2016 Tapglue. All rights reserved.
//

open class Like: Codable {
	fileprivate enum CodingKeys: String, CodingKey {
		case id
		case postId = "post_id"
		case externalId = "external_id"
		case userId = "user_id"
		case createdAt = "created_at"
		case updatedAt = "updated_at"
	}

    open var id: String?
    open var postId: String?
    open var externalId: String?
    open var userId: String?
    open var createdAt: String?
    open var updatedAt: String?
    open var user: User?
    open var post: Post?

    public init (postId: String) {
        self.postId = postId
    }
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decodeIfPresent(String.self, forKey: CodingKeys.id)
		postId = try container.decodeIfPresent(String.self, forKey: CodingKeys.postId)
		externalId = try container.decodeIfPresent(String.self, forKey: CodingKeys.externalId)
		userId = try container.decodeIfPresent(String.self, forKey: CodingKeys.userId)
		createdAt = try container.decodeIfPresent(String.self, forKey: CodingKeys.createdAt)
		updatedAt = try container.decodeIfPresent(String.self, forKey: CodingKeys.updatedAt)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(id, forKey: CodingKeys.id)
		try container.encodeIfPresent(postId, forKey: CodingKeys.postId)
		try container.encodeIfPresent(externalId, forKey: CodingKeys.externalId)
		try container.encodeIfPresent(userId, forKey: CodingKeys.userId)
		try container.encodeIfPresent(createdAt, forKey: CodingKeys.createdAt)
		try container.encodeIfPresent(updatedAt, forKey: CodingKeys.updatedAt)
	}
}
