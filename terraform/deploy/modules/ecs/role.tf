data "aws_iam_policy_document" "nook_ecs_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "ecs_task_role" {
  name_prefix        = "ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.nook_ecs_policy_doc.json
}

resource "aws_iam_role" "ecs_exec_role" {
  name_prefix        = "ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.nook_ecs_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec_role_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}