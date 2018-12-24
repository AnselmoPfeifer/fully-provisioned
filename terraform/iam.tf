resource "aws_iam_role" "ec2_role" {
  name = "AssumeS3Role"
  description = "Assume Role to allow S3 access"
  assume_role_policy = <<NODE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
NODE
}

resource "aws_iam_role_policy_attachment" "ec2-role-AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "${aws_iam_role.ec2_role.name}"
}
