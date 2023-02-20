class Faq {
  String? id;
  String? question;
  String? answer;

  Faq({this.id, this.question, this.answer});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['question'] = question;
    data['answer'] = answer;
    return data;
  }

  // ignore: non_constant_identifier_names
  factory Faq.fromJson(Map<String, dynamic> Json) {
    Faq newFilter =
        Faq(id: Json['id'], question: Json['question'], answer: Json['answer']);
    return newFilter;
  }
}
