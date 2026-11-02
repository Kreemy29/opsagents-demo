# Network rules for the orders service: the web tier calls the API tier, and the API tier
# sends callbacks back to the web tier.
resource "aws_security_group" "web" {
  name        = "orders-web"
  description = "Orders web tier"
  tags        = { service = "orders", tier = "web", owner = "payments" }

  ingress {
    description     = "Callbacks from the API tier"
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [aws_security_group.api.id]
  }
}

resource "aws_security_group" "api" {
  name        = "orders-api"
  description = "Orders API tier"
  tags        = { service = "orders", tier = "api", owner = "payments" }

  ingress {
    description     = "Requests from the web tier"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
}
