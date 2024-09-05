import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/progress_loader.dart';
import 'package:client/features/auth/view/pages/log_in.dart';
import 'package:client/features/auth/view/widgets/auth_gradient.button.dart';
import 'package:client/core/widgets/custom_form_field_text.dart';
import 'package:client/features/auth/viewModel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// add prefix to distinguish/resolve conflict in diff classes

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpStateWatch =
        ref.watch(authViewModelProvider.select((value) => value?.isLoading == true));

    ref.listen(
      authViewModelProvider,
      (prev, next) {
        next?.when(
          data: (data) {
            showSnackBar(context, 'Account created successfully');
            // ScaffoldMessenger.of(context)
            //   ..hideCurrentSnackBar()
            //   ..showSnackBar(
            //     SnackBar(
            //       content: Text(
            //         'Account created successfully',
            //       ),
            //     ),
            //   );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
          error: (error, stacktrace) {
            showSnackBar(context, error.toString());
          },
          loading: () {},
        );
      },
    );
    print(signUpStateWatch);
    return Scaffold(
            appBar: AppBar(),
            body: signUpStateWatch
        ? const Center(
            child: ProgressLoader(),
          ) :
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign Up!',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    CustomTextFormField(
                      text: 'Name',
                      controller: _nameController,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextFormField(
                      text: 'Email',
                      controller: _emailController,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextFormField(
                      text: 'Password',
                      controller: _passwordController,
                      isObscured: true,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    AuthGradientButton(
                      text: 'Sign Up',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await ref
                              .read(authViewModelProvider.notifier)
                              .signUpUser(
                                  name: _nameController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text);
                        }else{
                    showSnackBar(context, 'missing fields');}
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: Theme.of(context).textTheme.titleMedium,
                          children: const [
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: Pallete.gradient2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
